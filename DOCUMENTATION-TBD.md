# TBD UI Library Documentation
## Version 1.7.0 - Enhanced Edition

TBD UI Library is a modern, customizable Roblox UI library designed for script hubs and executors. This enhanced edition includes animated hover effects and an expanded dynamic icon library.

## Table of Contents
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Window Creation](#window-creation)
- [Tab System](#tab-system)
- [UI Elements](#ui-elements)
  - [Section](#section)
  - [Button](#button)
  - [Toggle](#toggle)
  - [Slider](#slider)
  - [Dropdown](#dropdown)
  - [Input Field](#input-field)
  - [Keybind](#keybind)
  - [Color Picker](#color-picker)
  - [Label](#label)
  - [Paragraph](#paragraph)
- [Special Features](#special-features)
  - [Animated Hover Effects](#animated-hover-effects)
  - [Dynamic Icon Library](#dynamic-icon-library)
  - [Home Page](#home-page)
  - [Notifications](#notifications)
  - [Loading Screen](#loading-screen)
  - [Theming](#theming)
- [API Reference](#api-reference)
- [Example Script](#example-script)

## Installation

To use the TBD UI Library, add the following line to your script:

```lua
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()
```

## Basic Usage

Here's a simple example to get started:

```lua
-- Load the library
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()

-- Create a window
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    Subtitle = "v1.0",
    Theme = "HoHo", -- Available themes: Default, Midnight, Neon, Aqua, HoHo
    ShowHomePage = true -- Show player info
})

-- Create a tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "Home" -- Icon names can be used directly from the icon library
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

Create a window with the following options:

```lua
local Window = TBD:CreateWindow({
    Title = "My Script Hub",     -- Title shown in the header
    Subtitle = "v1.0",           -- Subtitle shown in the header
    Size = {600, 400},           -- Width and height of the window (default: 550, 400)
    Position = "Center",         -- "Center" or {X, Y} coordinates
    Theme = "HoHo",              -- Default, Midnight, Neon, Aqua, HoHo
    LogoId = "rbxassetid://...", -- Optional logo image
    LoadingEnabled = true,       -- Show loading screen on startup
    LoadingTitle = "Loading...",  -- Title for loading screen
    LoadingSubtitle = "Please wait...", -- Subtitle for loading screen
    ShowHomePage = true,         -- Show home page with player info
    LoadingScreenCustomization = {
        AnimationStyle = "Fade", -- Animation style for loading screen
        LogoSize = {120, 120},   -- Size of logo on loading screen
        LogoPosition = {0.5, 0.4}, -- Position of logo (0-1 scale)
        ProgressBarSize = {300, 8} -- Size of progress bar
    }
})
```

## Tab System

Create tabs to organize your UI:

```lua
local MainTab = Window:CreateTab({
    Name = "Main", -- Name of the tab
    Icon = "Home"  -- Icon for the tab (can use icon name, asset ID, or number)
})
```

## UI Elements

### Section

Sections help organize elements within a tab:

```lua
MainTab:CreateSection("General Settings")
```

### Button

Create interactive buttons:

```lua
MainTab:CreateButton({
    Name = "Click Me",           -- Button text
    Description = "Optional description", -- Tooltip text (optional)
    Icon = "Bell",               -- Button icon (optional)
    Callback = function()        -- Function to run when clicked
        print("Button clicked!")
    end
})
```

### Toggle

Create toggleable options:

```lua
local toggle = MainTab:CreateToggle({
    Name = "Toggle Option",
    Description = "Enable or disable feature", -- Optional
    CurrentValue = false,        -- Starting state
    Callback = function(value)
        print("Toggle set to:", value)
    end,
    Flag = "myToggle"            -- Optional identifier for global access
})

-- You can access or set the toggle through its returned object
toggle:Set(true) -- Programmatically toggle
```

### Slider

Create adjustable sliders:

```lua
local slider = MainTab:CreateSlider({
    Name = "Speed",
    Description = "Adjust player speed", -- Optional
    Range = {0, 100},            -- Min and max values
    Increment = 1,               -- Step size
    CurrentValue = 50,           -- Starting value
    Callback = function(value)
        print("Slider value:", value)
    end,
    Flag = "speedSlider"         -- Optional identifier for global access
})

-- Programmatically set the slider value
slider:Set(75)
```

### Dropdown

Create selection menus:

```lua
local dropdown = MainTab:CreateDropdown({
    Name = "Select Option",
    Description = "Choose from the list", -- Optional
    Options = {"Option 1", "Option 2", "Option 3"},
    CurrentOption = "Option 1", -- Starting option
    Callback = function(option)
        print("Selected:", option)
    end,
    Flag = "optionSelect"        -- Optional identifier for global access
})

-- Programmatically set the dropdown option
dropdown:Set("Option 2")
```

### Input Field

Create text input fields:

```lua
local input = MainTab:CreateInput({
    Name = "Enter Text",
    Description = "Type your message", -- Optional
    Placeholder = "Text here...",  -- Placeholder text
    CurrentValue = "",            -- Starting value
    Callback = function(text)
        print("Input:", text)
    end,
    Flag = "inputText"           -- Optional identifier for global access
})
```

### Keybind

Create customizable keybinds:

```lua
local keybind = MainTab:CreateKeybind({
    Name = "Toggle UI",
    Description = "Key to show/hide UI", -- Optional
    CurrentKeybind = "RightShift", -- Default key
    Callback = function()
        print("Keybind pressed!")
    end,
    Flag = "toggleUIBind"        -- Optional identifier for global access
})
```

### Color Picker

Create color selection tools:

```lua
local colorPicker = MainTab:CreateColorPicker({
    Name = "UI Color",
    Description = "Change the accent color", -- Optional
    CurrentColor = Color3.fromRGB(255, 0, 0), -- Starting color
    Callback = function(color)
        print("Color selected:", color)
    end,
    Flag = "uiColor"             -- Optional identifier for global access
})
```

### Label

Create simple text labels:

```lua
MainTab:CreateLabel({
    Text = "This is a label"
})
```

### Paragraph

Create multi-line text blocks:

```lua
MainTab:CreateParagraph({
    Title = "Information",
    Content = "This is a paragraph with multiple lines of text that will automatically wrap."
})
```

## Special Features

### Animated Hover Effects

The Enhanced Edition includes sophisticated hover animations for buttons, tabs, and other interactive elements:

- **Growth/shrink animations**: Elements subtly expand and contract when hovered to provide visual feedback
- **Color transitions**: Smooth color blending with theme integration (buttons blend with accent colors)
- **Subtle glow effects**: Soft radiance appears around elements on hover using ImageLabels
- **Text size changes**: Text subtly enlarges for better readability and feedback
- **Position adjustments**: Elements reposition slightly to maintain proper centering during size changes

These effects are automatically applied to all interactive elements without requiring additional code. The animations use easing styles like Quad and Quart to create smooth, professional transitions that make the UI feel more responsive and modern.

#### Button Hover Effects
When hovering over buttons, you'll notice:
- The button expands slightly
- A soft glow appears behind the button
- The background color shifts toward the accent color
- Text becomes slightly larger

#### Tab Hover Effects
Tabs provide feedback through:
- Enlargement of the tab button
- Icon size increase
- Color transitions from secondary to primary text color
- Background opacity changes

### Dynamic Icon Library

The Enhanced Edition includes a significantly expanded icon library with over 90 built-in icons carefully categorized by type. This makes it easy to find the perfect icon for your UI elements without needing to search for external assets.

#### Icon Categories

| Category | Example Icons | Description |
|----------|--------------|-------------|
| Essential UI | Home, Settings, Search, Close | Basic interface control icons |
| Game Elements | Player, Target, Crown, Trophy | Icons related to gaming concepts |
| Actions | Play, Download, Save, Edit | Icons representing user actions |
| Communication | Chat, Mail, Share, Phone | Icons for communication features |
| Navigation | Compass, Location, Map, Route | Icons for navigation and mapping |
| UI Elements | Slider, Toggle, Button, Dropdown | Icons representing UI components |
| Categories | Folder, File, Image, Audio | Icons for categorizing content |
| Tools | Sword, Shield, Magic, Key | Icons for tools and abilities |
| Social | User, Users, AddUser, UserCheck | Icons for social interactions |
| Devices | Desktop, Laptop, Mobile, Tablet | Icons for different devices |
| Weather | Sun, Moon, Cloud, Rain | Icons for weather states |
| Misc | Chart, Calendar, Tag, Gift | Various utility icons |

#### Using Icons by Name

The most convenient way to use icons is by referencing their names directly in components:

```lua
-- Using icons in tabs
local PlayersTab = Window:CreateTab({
    Name = "Players",
    Icon = "User" -- Simply use the icon name
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "Settings"
})

-- Using icons in buttons
MainTab:CreateButton({
    Name = "Add Friend",
    Icon = "AddUser",
    Callback = function() end
})

MainTab:CreateButton({
    Name = "Save Configuration",
    Icon = "Save",
    Callback = function() end
})
```

#### GetIcon Helper Function

The Enhanced Edition includes a powerful `GetIcon` helper function that offers multiple ways to retrieve icons:

```lua
-- Get icon asset ID by name
local homeIcon = TBD:GetIcon("Home") 
-- Returns: "rbxassetid://7733960981"

-- Add prefix to numeric ID
local sameIcon = TBD:GetIcon(7733960981)
-- Returns: "rbxassetid://7733960981"

-- Pass through already formatted IDs
local customIcon = TBD:GetIcon("rbxassetid://12345678")
-- Returns: "rbxassetid://12345678"

-- Handles nil values with default icon
local defaultIcon = TBD:GetIcon(nil)
-- Returns a default icon
```

This function makes it extremely flexible to work with icons in your script. You can use string names, asset IDs, or already formatted rbxassetid strings interchangeably.

#### Icon Naming Convention

Icons follow a simple naming convention with PascalCase formatting. The first letter is always capitalized. Examples:

- Single word: "Home", "Settings", "User"
- Multiple words: "AddUser", "ColorPicker", "ChevronDown"

#### Full Icon List

For a complete list of all available icons, you can print them using:

```lua
for name, _ in pairs(Icons) do
    print(name)
end
```

## Troubleshooting

### Common Issues and Solutions

#### Dropdown Menu Not Showing
If dropdown menus aren't displaying correctly:
1. Make sure you're using the enhanced V7 version of the library
2. Check that the Options array contains valid entries
3. The dropdown positioning has been completely fixed in V7

#### Color Picker Issues
If color pickers aren't working properly:
1. The enhanced V7 version includes fixes for the color picker functionality
2. Ensure you're setting a valid Color3 value for CurrentColor
3. The RGB sliders now properly update the color preview

#### Theme System Not Updating
If theme changes aren't applying to all elements:
1. The V7 enhanced version includes an improved theme tracking system
2. All UI elements now properly update when the theme is changed
3. Make sure you're using the correct theme name

## Migration Guide

### Upgrading from Previous Versions

If you're migrating from an older version of the TBD UI Library, follow these steps:

1. **Update the loadstring URL**:
   ```lua
   -- Old version
   local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/main/tbd.lua"))()
   
   -- Enhanced V7 version
   local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua"))()
   ```

2. **Update UI element creation syntax**:
   Make sure all UI elements use the table format instead of separate parameters:
   ```lua
   -- Old version
   Tab:CreateButton("Button Name", function() end)
   
   -- Enhanced V7 version
   Tab:CreateButton({
       Name = "Button Name",
       Callback = function() end
   })
   ```

3. **Take advantage of new features**:
   - Use icon names directly in components
   - Implement the home page feature
   - Explore the animated hover effects

## Conclusion

The TBD UI Library Enhanced Edition builds upon the solid foundation of previous versions, adding sophisticated hover animations and a comprehensive icon library while fixing critical issues. The result is a polished, professional UI toolkit that elevates the user experience in Roblox script hubs and executors.

For additional support or questions, refer to the GitHub repository or contact the library developer.



## Example Script

See the `fixed-example-v7-enhanced.lua` file for a complete example that demonstrates all features of the Enhanced Edition.

```lua
-- Load the library
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()

-- Create a window with custom settings
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    Subtitle = "Enhanced Edition",
    Theme = "HoHo",
    Size = {650, 500},
    ShowHomePage = true,
    LoadingEnabled = true
})

-- Create tabs with icons from the dynamic icon library
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "Home"  -- Using icon name instead of asset ID
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "Settings"
})

-- Add UI elements
MainTab:CreateSection("Features")

MainTab:CreateButton({
    Name = "Example Button",
    Description = "Click to see the hover animation effect",
    Icon = "Bell",
    Callback = function()
        TBD:Notification({
            Title = "Welcome!",
            Message = "Thanks for using TBD UI Library.",
            Duration = 5,
            Type = "Success"
        })
    end
})

-- Add toggles with enhanced hover effects
MainTab:CreateToggle({
    Name = "Feature Toggle",
    Description = "Enable or disable a feature",
    CurrentValue = false,
    Callback = function(value)
        print("Toggle set to:", value)
    end
})

-- Add a slider
MainTab:CreateSlider({
    Name = "Speed Adjustment",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        print("Speed set to:", value)
    end
})

-- Add a dropdown with improved positioning
MainTab:CreateDropdown({
    Name = "Select Option",
    Options = {"Option 1", "Option 2", "Option 3"},
    CurrentOption = "Option 1",
    Callback = function(option)
        print("Selected:", option)
    end
})

-- Add a color picker with fixed functionality
MainTab:CreateColorPicker({
    Name = "UI Color",
    CurrentColor = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("Color selected:", color)
    end
})

-- Add theme settings
SettingsTab:CreateSection("UI Customization")

local themes = {"Default", "Midnight", "Neon", "Aqua", "HoHo"}
SettingsTab:CreateDropdown({
    Name = "UI Theme",
    Options = themes,
    CurrentOption = "HoHo",
    Callback = function(theme)
        TBD:SetTheme(theme)
    end
})

-- Access icons from the expanded library
SettingsTab:CreateSection("Icon Examples")

local iconNames = {"User", "Settings", "Home", "Search", "Bell", "Save", "Heart", "Target", "Crown", "Sword"}
for _, iconName in pairs(iconNames) do
    SettingsTab:CreateButton({
        Name = iconName,
        Icon = iconName,
        Callback = function()
            TBD:Notification({
                Title = "Icon Used",
                Message = "You clicked the " .. iconName .. " icon!",
                Duration = 3,
                Type = "Info"
            })
        end
    })
end
