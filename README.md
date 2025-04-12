# TBD UI Library - New Edition

A modern, feature-rich Roblox UI library for script hubs and executors, inspired by popular designs like HoHo UI.

## Features

1. **Redesigned UI**: Completely redesigned with a wider layout for better usability
2. **Modern Aesthetics**: Sleek, dark theme with accent colors and smooth animations
3. **Customizable Loading Screen**: Professional loading screen with animation options
4. **Window Controls**: Proper minimize and close buttons
5. **Homepage Feature**: Display player info, game details, and credits on a home page
6. **Fixed Notifications**: Properly positioned notifications with multiple types (Success, Info, Warning, Error)
7. **Executor Compatibility**: Works across different Roblox executors with fallback mechanisms
8. **Mobile Support**: Automatically adjusts for mobile devices with touch-friendly controls
9. **Full Element Set**: All UI elements (buttons, toggles, sliders, dropdowns, etc.) fully functional
10. **HoHo Theme**: New theme inspired by popular Roblox script hubs

## Installation

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()
```

## Quick Start Example

```lua
-- Load the library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()

-- Create a window with the home page feature enabled
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v2.0.0",
    Theme = "HoHo",
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
    Message = "TBD UI Library HoHo Edition has been loaded successfully!",
    Type = "Success",
    Duration = 5
})
```

## Documentation

For complete documentation on all features and API methods, please see the [DOCUMENTATION.md](DOCUMENTATION.md) file.

## Executor Compatibility

The HoHo Edition has been improved to work with various Roblox executors through:

1. Fallback implementation for GetSafeInsets method
2. Mobile device detection that works across executors
3. Error handling for executor-specific limitations

## Credits

- Original concept inspired by various Roblox UI libraries
- Enhanced and redesigned with inspiration from HoHo UI
