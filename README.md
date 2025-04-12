# TBD UI Library

A modern, feature-rich Roblox UI library for script hubs and executors.

![TBD UI Library](https://i.ibb.co/MkwVJpJt/giphy-5.gif)

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
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/main/tbd.lua", true))()
```

## Getting Started

### Creating a Window

```lua
local Window = TBD:CreateWindow({
    Title = "My Script Hub",                      -- Title of the window
    Subtitle = "v1.0.0",                          -- Optional subtitle
    Theme = "Default",                            -- "Default", "Midnight", or "Neon"
    Size = {450, 550},                            -- Width, Height
    Position = "Center",                          -- "Center" or {X, Y} coordinates
    LogoId = "12345678",                          -- Optional logo (AssetId)
    LoadingEnabled = true,                        -- Enable/disable loading screen
    LoadingTitle = "My Script Hub",               -- Loading screen title
    LoadingSubtitle = "Preparing...",             -- Loading screen subtitle
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
TBD:SetTheme("Midnight")  -- "Default", "Midnight", "Neon"

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

### Cleanup

```lua
-- Destroy the UI when no longer needed
TBD:Destroy()
```

## Complete Example

```lua
-- Load the TBD UI Library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/main/tbd.lua", true))()

-- Create a window
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    Subtitle = "v1.0.0",
    Theme = "Default",
    Size = {450, 550},
    Position = "Center",
    LoadingEnabled = true,
    LoadingTitle = "My Script Hub",
    LoadingSubtitle = "Preparing...",
    ConfigSettings = {
        ConfigFolder = "MyScriptHub"
    }
})

-- Create tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
    ImageSource = "Phosphor"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Phosphor"
})

-- Add UI elements to Main tab
MainTab:CreateSection("Player Settings")

MainTab:CreateToggle({
    Name = "Toggle Fly",
    Description = "Enable/disable fly mode",
    CurrentValue = false,
    Callback = function(Value)
        -- Implementation for fly hack
    end
}, "FlyToggle")

MainTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Adjust your character's walk speed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
}, "WalkSpeed")

MainTab:CreateDivider()

MainTab:CreateSection("Game Functions")

MainTab:CreateButton({
    Name = "Teleport to Lobby",
    Callback = function()
        -- Implementation for teleport
        TBD:Notification({
            Title = "Teleporting",
            Message = "You are being teleported to the lobby...",
            Type = "Info"
        })
    end
})

-- Add UI elements to Settings tab
SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateDropdown({
    Name = "Theme",
    Items = {"Default", "Midnight", "Neon"},
    Default = "Default",
    Callback = function(Theme)
        TBD:SetTheme(Theme)
    end
}, "UITheme")

SettingsTab:CreateColorPicker({
    Name = "Custom Accent Color",
    Color = Color3.fromRGB(64, 90, 255),
    Callback = function(Color)
        TBD:CustomTheme({
            Primary = Color,
            PrimaryDark = Color:Lerp(Color3.new(0, 0, 0), 0.2)
        })
    end
}, "AccentColor")

SettingsTab:CreateButton({
    Name = "Save Configuration",
    Callback = function()
        TBD:SaveConfig("UserConfig")
        TBD:Notification({
            Title = "Configuration Saved",
            Message = "Your settings have been saved!",
            Type = "Success"
        })
    end
})

-- Load auto-save config at the end of your script
TBD:LoadAutoloadConfig()
```

## Customization Reference

### Theme Properties

These properties can be used with `TBD:CustomTheme()`:

| Property | Description |
|----------|-------------|
| Primary | Main accent color |
| PrimaryDark | Darker version of accent color |
| Background | Main window background |
| ContainerBackground | Container background color |
| SecondaryBackground | Secondary background color |
| ElementBackground | UI element background color |
| TextPrimary | Primary text color |
| TextSecondary | Secondary/dimmed text color |
| Success | Success indicator color |
| Warning | Warning indicator color |
| Error | Error indicator color |
| Info | Information indicator color |
| InputBackground | Background of input fields |
| Highlight | Highlight/hover color |
| BorderColor | Border color for elements |
| DropShadowEnabled | Enable/disable drop shadows |
| RoundingEnabled | Enable/disable rounded corners |
| CornerRadius | Corner radius for UI elements |
| AnimationSpeed | Animation duration in seconds |
| GlassEffect | Enable/disable glass effect |
| BlurIntensity | Blur intensity for glass effect |
| Transparency | Background transparency |
| Font | UI font |
| HeaderSize | Header text size |
| TextSize | Normal text size |
| IconPack | Default icon pack ("Material" or "Phosphor") |

## Available Icons

### Material Design Icons

Common icons available in the Material design set:

`home`, `settings`, `search`, `close`, `add`, `remove`, `warning`, `info`, `check`, `error`, `notification`, `folder`, `person`, `star`, `favorite`, `dashboard`, `code`, `games`

### Phosphor Icons

Common icons available in the Phosphor design set:

`home`, `settings`, `search`, `close`, `add`, `remove`, `warning`, `info`, `check`, `error`, `notification`, `folder`, `person`, `star`, `favorite`, `dashboard`, `code`, `games`

## License

[MIT License](LICENSE) - Feel free to use, modify and distribute as needed.

## Credits

Developed by TBD Development Team
