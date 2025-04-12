# TBD UI Library - Enhanced Documentation

## Table of Contents

- [Introduction](#introduction)
- [What's New in v1.1.0](#whats-new-in-v110)
- [Getting Started](#getting-started)
  - [Installing the Library](#installing-the-library)
  - [Creating a Window](#creating-a-window)
  - [Customizing the Loading Screen](#customizing-the-loading-screen)
  - [Key System Setup](#key-system-setup)
  - [Working with Tabs](#working-with-tabs)
  - [Configuration System](#configuration-system)
- [UI Elements](#ui-elements)
  - [Sections](#sections)
  - [Dividers](#dividers)
  - [Buttons](#buttons)
  - [Toggles](#toggles)
  - [Sliders](#sliders)
  - [Input Fields](#input-fields)
  - [Dropdowns](#dropdowns)
  - [Color Pickers](#color-pickers)
- [Notifications](#notifications)
  - [Notification Types](#notification-types)
  - [Customizing Notifications](#customizing-notifications)
- [Theming](#theming)
  - [Built-in Themes](#built-in-themes)
  - [Custom Themes](#custom-themes)
  - [Icon Packs](#icon-packs)
- [Mobile Support](#mobile-support)
- [Advanced Features](#advanced-features)
  - [Configuration Flags](#configuration-flags)
  - [Saving and Loading Configurations](#saving-and-loading-configurations)
  - [Method Reference](#method-reference)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Introduction

TBD UI Library is a powerful, modern UI library for Roblox designed specifically for script hubs and executors. It provides a comprehensive set of tools and components for creating professional-looking interfaces with minimal effort.

Key features include:
- Modern design with rounded corners, animations, and glass effects
- Comprehensive component library
- Multiple built-in themes with customization options
- Robust key system for script protection
- Advanced configuration system for saving user settings
- Elegant notification system

## What's New in v1.1.0

The enhanced version includes several major improvements:

1. **Improved Mobile Support**
   - Automatic device detection
   - Responsive sizing and layout
   - Larger touch targets for mobile users
   - Optimized for different screen sizes

2. **Fixed Notification System**
   - Properly positioned notifications on all devices
   - Accounts for safe areas and screen boundaries
   - Customizable notification position

3. **Enhanced Window Controls**
   - Better close and minimize buttons
   - More responsive dragging behavior
   - Proper scaling for different devices

4. **Customizable Loading Screen**
   - Three animation styles: Fade, Slide, and Scale
   - Customizable element positioning
   - Configurable loading screen appearance

5. **New Theme: Aqua**
   - Fresh cyan-based color scheme
   - Clean, modern appearance
   - Optimized for readability

6. **Better Error Handling**
   - Comprehensive error checking
   - Graceful fallbacks
   - Detailed warning messages

7. **Performance Optimizations**
   - More efficient rendering
   - Better memory management
   - Dynamic layout updates

## Getting Started

### Installing the Library

To use TBD UI Library in your script, include the following code at the beginning of your script:

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()
```

### Creating a Window

A window is the main container for your interface. The enhanced version offers more customization options:

```lua
local Window = TBD:CreateWindow({
    Title = "My Amazing Script",                -- Window title
    Subtitle = "v1.0.0",                        -- Optional subtitle
    Theme = "Aqua",                             -- Theme (Default, Midnight, Neon, Aqua)
    Size = {500, 600},                          -- Window size (Width, Height)
    Position = "Center",                        -- Window position ("Center" or {X, Y})
    LogoId = "12345678",                        -- Optional logo AssetId
    LoadingEnabled = true,                      -- Show loading screen
    LoadingTitle = "My Amazing Script",         -- Loading screen title
    LoadingSubtitle = "by Me",                  -- Loading screen subtitle
    
    -- NEW: Loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Fade",                -- "Fade", "Slide", or "Scale"
        LogoSize = UDim2.new(0, 100, 0, 100),   -- Size of the logo
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0), -- Position of the logo
        TitlePosition = UDim2.new(0.5, 0, 0.55, 0), -- Position of the title
        SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0), -- Position of the subtitle
        ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0), -- Position of the progress bar
        ProgressBarSize = UDim2.new(0.7, 0, 0, 6) -- Size of the progress bar
    },
    
    -- Configuration settings (optional)
    ConfigSettings = {
        ConfigFolder = "MyScript"              -- Folder name for saved configs
    },
    
    -- Key system (optional)
    KeySystem = false                          -- Enable/disable key system
})
```

All parameters are optional except `Title`. The default window size is adjusted automatically for mobile devices.

### Customizing the Loading Screen

The enhanced version allows for extensive loading screen customization:

```lua
LoadingScreenCustomization = {
    -- Animation style for entering/exiting
    AnimationStyle = "Fade",  -- Options: "Fade", "Slide", "Scale"
    
    -- Optional: Custom background color (uses theme Background by default)
    BackgroundColor = Color3.fromRGB(15, 15, 20),
    
    -- Element sizing and positioning
    LogoSize = UDim2.new(0, 120, 0, 120),
    LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
    TitlePosition = UDim2.new(0.5, 0, 0.55, 0),
    SubtitlePosition = UDim2.new(0.5, 0, 0.62, 0),
    ProgressBarPosition = UDim2.new(0.5, 0, 0.75, 0),
    ProgressBarSize = UDim2.new(0.7, 0, 0, 6)
}
```

Animation Styles:
- `"Fade"` - Elements fade in and out smoothly
- `"Slide"` - Loading screen slides in from bottom and exits upward
- `"Scale"` - Loading screen grows from center and shrinks when done

### Key System Setup

The key system allows you to protect your script with an authentication mechanism. To enable it, set `KeySystem` to `true` and provide additional settings:

```lua
local Window = TBD:CreateWindow({
    Title = "Protected Script",
    
    KeySystem = true,                           -- Enable key system
    KeySettings = {
        Title = "Authentication Required",      -- Key system title
        Subtitle = "Key Verification",          -- Key system subtitle
        Note = "Get your key from our Discord", -- Informational note
        SaveKey = true,                         -- Remember key for future sessions
        Keys = {                                -- List of valid keys
            "key123", 
            "premium-key", 
            "hwid-based-key-123456789"
        },
        SecondaryAction = {
            Enabled = true,                    -- Enable secondary action
            Type = "Discord",                  -- "Discord" or "Link"
            Parameter = "YourDiscordInvite"    -- Discord invite code or full URL
        }
    }
})
```

### Working with Tabs

Tabs help organize your interface into logical sections:

```lua
local MainTab = Window:CreateTab({
    Name = "Main Features",           -- Tab name
    Icon = "home",                    -- Icon name
    ImageSource = "Phosphor",         -- Icon set ("Material" or "Phosphor")
    ShowTitle = true                  -- Show title in tab content
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Phosphor"
})
```

### Configuration System

TBD includes a powerful configuration system that automatically saves and loads user settings. To enable it, define the configuration folder in your window settings:

```lua
local Window = TBD:CreateWindow({
    Title = "My Script",
    ConfigSettings = {
        ConfigFolder = "MyScriptConfigs"    -- Folder name for configs
    }
})
```

Then, add the following at the end of your script to automatically load the last saved configuration:

```lua
TBD:LoadAutoloadConfig()
```

## UI Elements

### Sections

Sections help organize UI elements within a tab:

```lua
local Section = MainTab:CreateSection("Combat Features")
```

Methods:
- `Section:Set("New Section Name")` - Change section name
- `Section:Destroy()` - Remove the section

### Dividers

Dividers create a simple horizontal line to separate content:

```lua
MainTab:CreateDivider()
```

### Buttons

Buttons perform actions when clicked:

```lua
local Button = MainTab:CreateButton({
    Name = "Activate Power",                  -- Button text
    Description = "Gives you superpowers",    -- Optional description
    Callback = function()                     -- Function to run when clicked
        print("Button clicked!")
        -- Your code here
    end
})
```

Methods:
- `Button:Set(function() end)` - Change the callback function
- `Button:SetName("New Name")` - Change button text
- `Button:SetDescription("New description")` - Change description

### Toggles

Toggles represent on/off states:

```lua
local Toggle = MainTab:CreateToggle({
    Name = "Infinite Jump",                  -- Toggle name
    Description = "Never run out of jumps",  -- Optional description
    CurrentValue = false,                    -- Initial state (true/false)
    Callback = function(Value)               -- Function when toggled
        print("Toggle is now:", Value)
        -- Your code here
    end
}, "InfiniteJumpToggle")                     -- Config flag name
```

Methods:
- `Toggle:Set(true)` - Set toggle state (true/false)
- `Toggle:Toggle()` - Switch between states
- `Toggle:GetState()` - Returns current state
- `Toggle:SetCallback(function(Value) end)` - Change callback
- `Toggle:SetName("New Name")` - Change toggle name
- `Toggle:SetDescription("New description")` - Change description

### Sliders

Sliders allow selecting a value within a range:

```lua
local Slider = MainTab:CreateSlider({
    Name = "Player Speed",                  -- Slider name
    Description = "Adjust movement speed",  -- Optional description
    Range = {16, 250},                      -- Min and max values
    Increment = 1,                          -- Step size
    CurrentValue = 16,                      -- Initial value
    Callback = function(Value)              -- Function when value changes
        print("Slider value:", Value)
        -- Your code here
    end
}, "PlayerSpeedSlider")                     -- Config flag name
```

Methods:
- `Slider:Set(50)` - Set slider value
- `Slider:GetValue()` - Returns current value
- `Slider:SetRange(10, 300)` - Change min/max values
- `Slider:SetIncrement(5)` - Change step size
- `Slider:SetCallback(function(Value) end)` - Change callback

### Input Fields

Input fields allow text entry:

```lua
local Input = MainTab:CreateInput({
    Name = "Target Player",                   -- Input name
    Description = "Enter player to target",   -- Optional description
    PlaceholderText = "Username...",          -- Placeholder when empty
    Default = "",                             -- Initial value
    Callback = function(Text, EnterPressed)   -- Function when text changes
        print("Input:", Text)
        print("Enter key pressed:", EnterPressed)
        -- Your code here
    end
}, "TargetPlayerInput")                       -- Config flag name
```

Methods:
- `Input:Set("New text")` - Set input text
- `Input:GetValue()` - Returns current text
- `Input:SetCallback(function(Text, EnterPressed) end)` - Change callback

### Dropdowns

Dropdowns allow selecting from a list of options:

```lua
local Dropdown = MainTab:CreateDropdown({
    Name = "Teleport Location",               -- Dropdown name
    Description = "Choose where to teleport", -- Optional description
    Items = {"Lobby", "Dungeon", "Boss Room"},-- List of items
    Default = "Lobby",                        -- Initial selection
    Callback = function(Option)               -- Function when selection changes
        print("Selected:", Option)
        -- Your code here
    end
}, "TeleportLocationDropdown")                -- Config flag name
```

Methods:
- `Dropdown:Set("Dungeon")` - Set selected item
- `Dropdown:GetValue()` - Returns currently selected item
- `Dropdown:SetItems({"New", "Item", "List"})` - Replace all items
- `Dropdown:AddItem("New Item")` - Add a single item
- `Dropdown:RemoveItem("Item")` - Remove an item
- `Dropdown:SetCallback(function(Option) end)` - Change callback

### Color Pickers

Color pickers allow selecting a color:

```lua
local ColorPicker = MainTab:CreateColorPicker({
    Name = "ESP Color",                      -- Color picker name
    Description = "Select ESP highlight color", -- Optional description
    Color = Color3.fromRGB(255, 0, 0),       -- Initial color (red)
    Callback = function(Color)               -- Function when color changes
        print("Color selected:", Color)
        -- Your code here
    end
}, "ESPColorPicker")                         -- Config flag name
```

Methods:
- `ColorPicker:Set(Color3.fromRGB(0, 255, 0))` - Set color value
- `ColorPicker:GetColor()` - Returns current color
- `ColorPicker:SetCallback(function(Color) end)` - Change callback

## Notifications

The notification system has been completely rebuilt to work properly on all devices.

### Notification Types

TBD supports four notification types: Info, Success, Warning, and Error.

```lua
-- Info notification (blue)
TBD:Notification({
    Title = "Information",
    Message = "This is an informational message",
    Type = "Info" -- This is the default type if not specified
})

-- Success notification (green)
TBD:Notification({
    Title = "Success",
    Message = "Operation completed successfully!",
    Type = "Success"
})

-- Warning notification (yellow/orange)
TBD:Notification({
    Title = "Warning",
    Message = "Please be careful with this action",
    Type = "Warning"
})

-- Error notification (red)
TBD:Notification({
    Title = "Error",
    Message = "Something went wrong!",
    Type = "Error"
})
```

### Customizing Notifications

Notifications can be customized with several options:

```lua
TBD:Notification({
    Title = "Task Complete",                 -- Notification title
    Message = "Operation was successful!",   -- Notification message
    Duration = 5,                            -- Display time in seconds (default: 5)
    Type = "Success",                        -- Type: "Info", "Success", "Warning", "Error"
    Icon = "check",                          -- Icon name or AssetId
    Callback = function()                    -- Optional function when clicked
        print("Notification clicked")
    end
})
```

**NEW:** You can now change the position where notifications appear:

```lua
-- Change where notifications appear on screen
TBD.NotificationSystem:SetPosition("BottomRight")

-- Available positions:
-- "TopRight" (default)
-- "TopLeft"
-- "BottomRight"
-- "BottomLeft"
```

You can also customize the default duration for all notifications:

```lua
-- Set default notification duration to 3 seconds
TBD.NotificationSystem.DefaultDuration = 3
```

## Theming

### Built-in Themes

TBD now includes four built-in themes:
- `Default` - Dark blue/purple theme
- `Midnight` - Deep purple theme
- `Neon` - Vibrant cyan theme
- `Aqua` - New cyan/blue theme (added in v1.1.0)

To switch themes:

```lua
TBD:SetTheme("Aqua")
```

### Custom Themes

You can create custom themes by overriding specific theme properties:

```lua
TBD:CustomTheme({
    -- Core Colors
    Primary = Color3.fromRGB(255, 0, 0),           -- Main accent color (red)
    PrimaryDark = Color3.fromRGB(200, 0, 0),       -- Darker accent
    Background = Color3.fromRGB(15, 15, 15),       -- Main background
    ContainerBackground = Color3.fromRGB(25, 25, 30), -- Container background
    SecondaryBackground = Color3.fromRGB(35, 35, 40), -- Secondary background
    ElementBackground = Color3.fromRGB(45, 45, 50),   -- UI element background
    
    -- Text Colors
    TextPrimary = Color3.fromRGB(240, 240, 240),   -- Main text color
    TextSecondary = Color3.fromRGB(180, 180, 180), -- Secondary text
    
    -- Status Colors
    Success = Color3.fromRGB(70, 230, 130),        -- Success indicators
    Warning = Color3.fromRGB(255, 185, 65),        -- Warning indicators
    Error = Color3.fromRGB(255, 70, 90),           -- Error indicators
    Info = Color3.fromRGB(70, 190, 255),           -- Info indicators
    
    -- Other UI Colors
    InputBackground = Color3.fromRGB(55, 55, 60),  -- Input field background
    Highlight = Color3.fromRGB(255, 0, 0),         -- Highlight/hover color
    BorderColor = Color3.fromRGB(60, 60, 65),      -- Border color
    
    -- Appearance Settings
    DropShadowEnabled = true,                      -- Enable/disable shadows
    RoundingEnabled = true,                        -- Enable/disable rounded corners
    CornerRadius = UDim.new(0, 10),                -- Corner roundness
    AnimationSpeed = 0.3,                          -- Animation duration
    GlassEffect = true,                            -- Enable glass effect
    BlurIntensity = 15,                            -- Blur amount
    Transparency = 0.95,                           -- UI transparency
    
    -- Typography
    Font = Enum.Font.GothamSemibold,               -- Main font
    HeaderSize = 18,                               -- Header text size
    TextSize = 14,                                 -- Regular text size
    
    -- Other Settings
    IconPack = "Phosphor",                         -- Icon set ("Material" or "Phosphor")
    MobileCompatible = true,                       -- Mobile optimization
    
    -- NEW: Loading Screen Customization
    LoadingScreenCustomization = {
        BackgroundColor = nil,                     -- Uses theme Background by default
        AnimationStyle = "Fade",                   -- "Fade", "Slide", or "Scale"
        LogoSize = UDim2.new(0, 100, 0, 100),
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0)
    }
})
```

### Icon Packs

TBD supports two icon packs:
- `Material` - Material Design icons
- `Phosphor` - Modern minimalist icons

You can specify which icon pack to use when creating tabs or in your theme settings.

## Mobile Support

The enhanced version includes comprehensive mobile support:

### Automatic Device Detection

TBD automatically detects if a device is using touch input and adjusts the UI accordingly:

- Larger buttons and interactive elements
- Adjusted spacing and padding
- Optimized layout for touch interaction
- Safe area insets for notched devices

### Mobile-Specific Adjustments

- Sidebar width is reduced on mobile
- Text sizes are increased for readability
- Icons are larger and easier to tap
- Notification positioning accounts for on-screen keyboards and system UI

### Mobile Testing

When testing on mobile:
- Ensure UI elements are large enough to tap comfortably
- Check that notifications appear in visible areas
- Verify scrolling behavior works smoothly
- Test with different screen orientations if possible

## Advanced Features

### Configuration Flags

Flags are used to identify UI elements in saved configurations. They can be specified when creating elements:

```lua
local Toggle = MainTab:CreateToggle({
    Name = "Wallhack",
    CurrentValue = false,
    Callback = function(Value) end
}, "WallhackToggle")  -- "WallhackToggle" is the flag name
```

If you don't specify a flag, the element's name will be used as the flag.

### Saving and Loading Configurations

TBD can save and load user configurations:

```lua
-- Save current settings
TBD:SaveConfig("MySettings")

-- Load saved settings
TBD:LoadConfig("MySettings")

-- Get a list of available configurations
local ConfigList = TBD:ListConfigs()
```

### Method Reference

Window Methods:
- `Window:CreateTab(options)` - Create a new tab
- `Window:SelectTab(tabId)` - Switch to a specific tab
- `Window:Close()` - Close the window

TBD Global Methods:
- `TBD:CreateWindow(options)` - Create a new window
- `TBD:Notification(options)` - Show a notification
- `TBD:SaveConfig(name)` - Save current configuration
- `TBD:LoadConfig(name)` - Load saved configuration
- `TBD:ListConfigs()` - List available configurations
- `TBD:LoadAutoloadConfig()` - Load auto-saved configuration
- `TBD:SetTheme(theme)` - Change active theme
- `TBD:GetTheme()` - Get current theme properties
- `TBD:CustomTheme(options)` - Apply custom theme
- `TBD:Destroy()` - Remove all UI elements

NEW Notification Methods:
- `TBD.NotificationSystem:SetPosition(position)` - Change notification position

## Best Practices

1. **Optimize for all devices**: Test your UI on both desktop and mobile if possible

2. **Organize with tabs and sections**: Keep your UI organized by using tabs for major categories and sections within tabs for subcategories.

3. **Use descriptive names**: Give your UI elements clear, descriptive names so users understand their purpose.

4. **Include descriptions**: Use the description parameter for complex features to provide additional context.

5. **Use consistent flags**: When using the configuration system, use consistent, descriptive flag names that won't conflict with each other.

6. **Load auto-save config**: Always include `TBD:LoadAutoloadConfig()` at the end of your script to restore user settings.

7. **Handle errors**: Wrap callback functions in pcall to handle potential errors gracefully.

8. **Clean up when done**: Call `TBD:Destroy()` when your script is no longer needed to clean up resources.

## Troubleshooting

**Issue**: UI elements don't save settings between sessions
- Make sure you're using flags with your elements
- Verify that the executor supports filesystem functions
- Check that you're calling `TBD:LoadAutoloadConfig()` at the end of your script

**Issue**: Icons don't appear correctly
- Check that the icon name is correct and exists in the specified icon pack
- Try using the other icon pack (`Material` or `Phosphor`)

**Issue**: UI appears glitchy or elements overlap
- Avoid creating too many elements in a single tab
- Use sections to organize content
- Check for errors in your callback functions

**Issue**: Key system doesn't work
- Ensure keys are entered exactly as defined (case-sensitive)
- Check that the executor supports filesystem functions for key saving

**Issue**: Custom theme doesn't apply correctly
- Make sure to call `TBD:CustomTheme()` after creating the window
- Check that you're using valid Color3 values

**Issue**: Notifications appear off-screen
- Try changing the notification position with `TBD.NotificationSystem:SetPosition("TopRight")`
- If still having issues, try updating to the latest library version

**Issue**: Mobile UI looks too small
- The enhanced version should automatically adjust for mobile, but if you're having issues, try setting larger sizes in your custom theme

For additional help, please reach out through GitHub issues or the provided contact information.
