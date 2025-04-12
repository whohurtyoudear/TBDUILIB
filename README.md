# TBD UI Library - Enhanced & Fixed

A modern, feature-rich Roblox UI library for script hubs and executors with comprehensive documentation and numerous improvements.

## Overview

TBD UI Library is designed to provide an elegant, customizable interface for Roblox script hubs and executors. This enhanced version includes fixes for compatibility issues and adds new features to improve user experience.

## Features

- **Modern Design**: Clean, glass-like interface with smooth animations and transitions
- **Responsive Layout**: Automatically adapts to different screen sizes and devices, including mobile support
- **Comprehensive Element Set**: Includes buttons, toggles, sliders, dropdowns, colorpickers, and more
- **Customizable Themes**: Choose from pre-built themes or create your own custom theme
- **Notification System**: Display elegant notifications with different types (success, info, warning, error)
- **Configuration System**: Save and load user configurations automatically
- **Home Page Feature**: Display player information, game details, and library credits
- **Executor Compatibility**: Fixed to work properly across different Roblox executors

## Recent Fixes & Improvements

1. **GetSafeInsets Compatibility**: Implemented fallback for executors that don't support GuiService:GetSafeInsets()
2. **CreateToggle Fix**: Added missing CreateToggle method 
3. **Notification Positioning**: Fixed notification positioning to correctly appear in the specified corner of the screen
4. **Home Page Feature**: Added a new home page that displays player information, game details, and UI library credits
5. **Mobile Support**: Improved mobile support with touch-friendly controls and responsive layouts
6. **Loading Screen**: Enhanced customizable loading screen with animation options
7. **Aqua Theme**: Added a new "Aqua" theme option

## Installation

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()
```

## Quick Start Example

```lua
-- Load the library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/tbd-enhanced-fixed.lua", true))()

-- Create a window with the home page feature enabled
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v1.1.0",
    Theme = "Aqua",
    ShowHomePage = true,
    LoadingEnabled = true
})

-- Create a tab
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
    ImageSource = "Phosphor"
})

-- Add a toggle (using the fixed CreateToggle method)
MainTab:CreateToggle({
    Name = "Test Feature",
    Description = "Enable or disable this feature",
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle is now set to:", Value)
    end
})

-- Fix notification positioning
TBD.NotificationSystem:SetPosition("TopRight")

-- Show a notification
TBD:Notification({
    Title = "Welcome",
    Message = "TBD UI Library has been loaded successfully!",
    Type = "Success",
    Duration = 5
})
```

## Documentation

For complete documentation on all features and API methods, please see the [DOCUMENTATION.md](DOCUMENTATION.md) file.

## Executor Compatibility

The enhanced library has been fixed to work with various Roblox executors through the following improvements:

1. Fallback implementation for GetSafeInsets method
2. Mobile device detection that works across executors
3. Error handling for executor-specific limitations

## Credits

- Original concept inspired by various Roblox UI libraries
- Enhanced and fixed by [Your Name/Team]
