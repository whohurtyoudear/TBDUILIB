# TBD UI Library - Documentation

## Table of Contents

- [Introduction](#introduction)
- [Getting Started](#getting-started)
  - [Installing the Library](#installing-the-library)
  - [Creating a Window](#creating-a-window)
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
- [Theming](#theming)
  - [Built-in Themes](#built-in-themes)
  - [Custom Themes](#custom-themes)
  - [Icon Packs](#icon-packs)
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

## Getting Started

### Installing the Library

To use TBD UI Library in your script, include the following code at the beginning of your script:

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/main/tbd.lua", true))()
```

### Creating a Window

A window is the main container for your interface. You can create a window with various customization options:

```lua
local Window = TBD:CreateWindow({
    Title = "My Amazing Script",                -- Window title
    Subtitle = "v1.0.0",                        -- Optional subtitle
    Theme = "Default",                          -- Theme (Default, Midnight, Neon)
    Size = {500, 600},                          -- Window size (Width, Height)
    Position = "Center",                        -- Window position ("Center" or {X, Y})
    LogoId = "12345678",                        -- Optional logo AssetId
    LoadingEnabled = true,                      -- Show loading screen
    LoadingTitle = "My Amazing Script",         -- Loading screen title
    LoadingSubtitle = "by Me",                  -- Loading screen subtitle
    
    -- Configuration settings (optional)
    ConfigSettings = {
        ConfigFolder = "MyScript"              -- Folder name for saved configs
    },
    
    -- Key system (optional)
    KeySystem = false                          -- Enable/disable key system
})
```

All parameters are optional except `Title`. The default window size is 400×500 pixels if not specified.

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

Notifications display temporary messages to the user:

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

## Theming

### Built-in Themes

TBD includes three built-in themes:
- `Default` - Dark blue/purple theme
- `Midnight` - Deep purple theme
- `Neon` - Vibrant cyan theme

To switch themes:

```lua
TBD:SetTheme("Midnight")
```

### Custom Themes

You can create custom themes by overriding specific theme properties:

```lua
TBD:CustomTheme({
    Primary = Color3.fromRGB(255, 0, 0),           -- Main accent color (red)
    PrimaryDark = Color3.fromRGB(200, 0, 0),       -- Darker accent
    Background = Color3.fromRGB(15, 15, 15),       -- Main background
    TextPrimary = Color3.fromRGB(240, 240, 240),   -- Main text color
    CornerRadius = UDim.new(0, 10),                -- Rounded corners
    -- Add any other theme properties to override
})
```

### Icon Packs

TBD supports two icon packs:
- `Material` - Material Design icons
- `Phosphor` - Modern minimalist icons

You can specify which icon pack to use when creating tabs or in your theme settings.

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

## Best Practices

1. **Organize with tabs and sections**: Keep your UI organized by using tabs for major categories and sections within tabs for subcategories.

2. **Use descriptive names**: Give your UI elements clear, descriptive names so users understand their purpose.

3. **Include descriptions**: Use the description parameter for complex features to provide additional context.

4. **Use consistent flags**: When using the configuration system, use consistent, descriptive flag names that won't conflict with each other.

5. **Load auto-save config**: Always include `TBD:LoadAutoloadConfig()` at the end of your script to restore user settings.

6. **Handle errors**: Wrap callback functions in pcall to handle potential errors gracefully.

7. **Clean up when done**: Call `TBD:Destroy()` when your script is no longer needed to clean up resources.

8. **Test thoroughly**: Test your UI on different screen sizes and with different executor environments.

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

For additional help, please reach out through GitHub issues or the provided contact information.