# TBD UI Library (Enhanced)

A modern, feature-rich Roblox UI library for script hubs and executors with improved mobile support and enhanced features.

![TBD UI Library](https://i.ibb.co/MkwVJpJt/giphy-5.gif)

## New Features in v1.1.0

- **Improved Mobile Support** - Fully responsive design with optimized layouts for touch screens
- **Fixed Notification System** - Properly positioned notifications on all screen sizes
- **Enhanced Window Controls** - Better close/minimize buttons and improved dragging
- **Customizable Loading Screen** - Choose from multiple animation styles and customize appearance
- **New Theme (Aqua)** - Beautiful new aqua-themed preset
- **Better Error Handling** - More robust error checking and graceful fallbacks
- **Performance Improvements** - Optimized for better performance across all devices

## Features

- **Modern Design** - Clean, sleek interface with smooth animations and rounded corners
- **Intuitive API** - Simple and straightforward API for creating beautiful UIs
- **Customization** - Multiple themes included with support for custom themes
- **Component Library** - Rich set of UI components including buttons, toggles, sliders, and more
- **Configuration System** - Save and load settings across sessions
- **Key System** - Protect your scripts with a built-in key authentication system
- **Notifications** - Elegant notification system with multiple types and customization options
- **Icon Packs** - Built-in support for Material Design and Phosphor icon sets
- **Optimized Performance** - Designed for minimal performance impact
- **Robust Error Handling** - Graceful handling of potential issues

## Installation

To use TBD UI Library in your Roblox script, simply use the loadstring function to load the library:

```lua
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()
```

## Getting Started

### Creating a Window

```lua
local Window = TBD:CreateWindow({
    Title = "My Script Hub",                      -- Title of the window
    Subtitle = "v1.0.0",                          -- Optional subtitle
    Theme = "Aqua",                               -- "Default", "Midnight", "Neon", or "Aqua"
    Size = {450, 550},                            -- Width, Height (auto-adjusts for mobile)
    Position = "Center",                          -- "Center" or {X, Y} coordinates
    LogoId = "12345678",                          -- Optional logo (AssetId)
    LoadingEnabled = true,                        -- Enable/disable loading screen
    LoadingTitle = "My Script Hub",               -- Loading screen title
    LoadingSubtitle = "Preparing...",             -- Loading screen subtitle
    
    -- New: Loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Fade",                  -- "Fade", "Slide", or "Scale"
        LogoSize = UDim2.new(0, 100, 0, 100),     -- Size of the logo
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0) -- Position of the logo
    },
    
    ConfigSettings = {                            -- Optional configuration settings
        ConfigFolder = "MyScriptHub"
    },
    KeySystem = false                             -- Enable/disable key system
})
```

### Key System (Optional)

If you want to protect your script with a key system, set `KeySystem` to `true` and configure it:

```lua
local Window = TBD:CreateWindow({
    -- ... other window settings ...
    KeySystem = true,
    KeySettings = {
        Title = "Authentication Required",
        Subtitle = "Enter your key",
        Note = "Get your key from our Discord server",
        SaveKey = true,                             -- Save key for future sessions
        Keys = {"key1", "key2", "HWID_based_key"},  -- List of valid keys
        SecondaryAction = {
            Enabled = true,
            Type = "Discord",                       -- "Discord" or "Link"
            Parameter = "discord-invite-code"       -- Discord invite code or full URL
        }
    }
})
```

### Creating Tabs

```lua
local MainTab = Window:CreateTab({
    Name = "Main",                -- Tab name
    Icon = "home",                -- Optional icon name
    ImageSource = "Phosphor",     -- "Material" or "Phosphor"
    ShowTitle = true              -- Show/hide title in the tab content
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Phosphor"
})
```

### Adding UI Elements

#### Sections

```lua
local Section = MainTab:CreateSection("Combat Settings")
```

#### Dividers

```lua
MainTab:CreateDivider() -- Creates a horizontal line divider
```

#### Buttons

```lua
local Button = MainTab:CreateButton({
    Name = "Click Me",
    Description = "This is a button with a description",  -- Optional
    Callback = function()
        print("Button clicked!")
    end
})

-- Update button callback
Button:Set(function()
    print("New callback!")
end)

-- Update button text
Button:SetName("New Button Text")
```

#### Toggles

```lua
local Toggle = MainTab:CreateToggle({
    Name = "Enable Feature",
    Description = "This toggle controls a feature",  -- Optional
    CurrentValue = false,
    Callback = function(Value)
        print("Toggle state:", Value)
    end
}, "ToggleFlag")  -- Config flag name for saving state

-- Set toggle state
Toggle:Set(true)

-- Toggle the current state
Toggle:Toggle()

-- Get current state
local state = Toggle:GetState()
```

#### Sliders

```lua
local Slider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Adjust your character's walk speed",  -- Optional
    Range = {16, 100},            -- Min and Max values
    Increment = 1,                -- Step size
    CurrentValue = 16,            -- Default value
    Callback = function(Value)
        print("Slider value:", Value)
    end
}, "WalkSpeedSlider")  -- Config flag name

-- Set slider value
Slider:Set(50)

-- Get current value
local value = Slider:GetValue()

-- Change slider range
Slider:SetRange(10, 150)
```

#### Input Fields

```lua
local Input = MainTab:CreateInput({
    Name = "Player Name",
    Description = "Enter a player's name",      -- Optional
    PlaceholderText = "Enter name...",          -- Optional placeholder
    Default = "",                               -- Default value
    Callback = function(Text, EnterPressed)
        print("Input text:", Text)
        print("Enter pressed:", EnterPressed)
    end
}, "PlayerNameInput")  -- Config flag name

-- Set input text
Input:Set("NewValue")

-- Get current text
local text = Input:GetValue()
```

#### Dropdowns

```lua
local Dropdown = MainTab:CreateDropdown({
    Name = "Select Option",
    Description = "Choose from available options",  -- Optional
    Items = {"Option 1", "Option 2", "Option 3"},
    Default = "Option 1",                           -- Optional default selection
    Callback = function(Selection)
        print("Selected:", Selection)
    end
}, "OptionDropdown")  -- Config flag name

-- Set selected item
Dropdown:Set("Option 2")

-- Get current selection
local selection = Dropdown:GetValue()

-- Update dropdown items
Dropdown:SetItems({"New Option 1", "New Option 2"})

-- Add a single item
Dropdown:AddItem("New Option 3")

-- Remove an item
Dropdown:RemoveItem("New Option 2")
```

#### Color Pickers

```lua
local ColorPicker = MainTab:CreateColorPicker({
    Name = "UI Color",
    Description = "Change the UI accent color",  -- Optional
    Color = Color3.fromRGB(64, 90, 255),         -- Default color
    Callback = function(Color)
        print("Selected color:", Color)
    end
}, "UIColorPicker")  -- Config flag name

-- Set color
ColorPicker:Set(Color3.fromRGB(255, 0, 0))

-- Get current color
local color = ColorPicker:GetColor()
```

### Notifications

```lua
-- Show a notification
TBD:Notification({
    Title = "Operation Complete",
    Message = "Your task has been successfully completed!",
    Duration = 5,                            -- Optional: Time in seconds to show (default: 5)
    Type = "Success",                        -- Optional: "Info", "Success", "Warning", "Error"
    Icon = "check",                          -- Optional: Icon name or AssetId
    Callback = function()                    -- Optional: Called when notification is clicked
        print("Notification clicked!")
    end
})
```

### Configuration Management

```lua
-- Save current settings
TBD:SaveConfig("MyConfig")

-- Load saved settings
TBD:LoadConfig("MyConfig")

-- Get list of available configs
local configs = TBD:ListConfigs()

-- Automatically load the most recent config
TBD:LoadAutoloadConfig()  -- Call this at the end of your script!
```

### Theming

```lua
-- Change active theme
TBD:SetTheme("Aqua")  -- "Default", "Midnight", "Neon", "Aqua"

-- Get current theme
local currentTheme = TBD:GetTheme()

-- Create custom theme
TBD:CustomTheme({
    Primary = Color3.fromRGB(255, 0, 0),
    PrimaryDark = Color3.fromRGB(200, 0, 0),
    Background = Color3.fromRGB(20, 20, 20),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    -- Override any theme properties
})
```

### New: Advanced Theme Customization

```lua
-- Create a completely custom theme
TBD:CustomTheme({
    -- Colors
    Primary = Color3.fromRGB(255, 75, 75),
    PrimaryDark = Color3.fromRGB(220, 55, 55),
    Background = Color3.fromRGB(25, 25, 35),
    ContainerBackground = Color3.fromRGB(35, 35, 45),
    SecondaryBackground = Color3.fromRGB(45, 45, 55),
    ElementBackground = Color3.fromRGB(55, 55, 65),
    TextPrimary = Color3.fromRGB(240, 240, 250),
    TextSecondary = Color3.fromRGB(180, 180, 190),
    
    -- Appearance
    CornerRadius = UDim.new(0, 10),
    DropShadowEnabled = true,
    AnimationSpeed = 0.25,
    Transparency = 0.95,
    
    -- Fonts
    Font = Enum.Font.SourceSansBold,
    HeaderSize = 20,
    TextSize = 15,
    
    -- Other
    IconPack = "Material",
    
    -- New: Loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Scale", -- "Fade", "Slide", "Scale"
        LogoSize = UDim2.new(0, 120, 0, 120),
        TitlePosition = UDim2.new(0.5, 0, 0.6, 0)
    }
})
```

### New: Customizing Notification Position

```lua
-- Change notification position
TBD.NotificationSystem:SetPosition("BottomRight")  -- "TopRight", "TopLeft", "BottomRight", "BottomLeft"
```

### Cleanup

```lua
-- Destroy the UI when no longer needed
TBD:Destroy()
```

## Complete Example

See the included [example-tbd-enhanced.lua](example-tbd-enhanced.lua) file for a complete demo of all features.

## Mobile Support

The enhanced TBD UI Library automatically detects and optimizes for mobile devices:

- Larger touch targets for better interaction
- Adjusted spacing and sizing for mobile screens
- On-screen controls optimized for touch
- Fixed notification positioning accounting for safe areas
- Improved scrolling behavior

## Troubleshooting

If you encounter any issues:

1. **UI not appearing**: Make sure you're using the correct URL in your loadstring
2. **Notifications appearing off-screen**: This should be fixed in the enhanced version; if issues persist, try setting the notification position manually with `TBD.NotificationSystem:SetPosition("TopRight")`
3. **Error messages**: The enhanced library includes better error handling with specific warning messages

## License

[MIT License](LICENSE) - Feel free to use, modify and distribute as needed.

## Credits

Developed by TBD Development Team
