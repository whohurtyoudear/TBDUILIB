# TBD UI Library - Enhanced Edition

TBD UI Library is a modern, powerful user interface library for Roblox script hubs and executors. This enhanced version (v7) includes animated hover effects and a comprehensive dynamic icon library to create sleek, responsive, and visually appealing UIs.

![TBD UI Library Preview](https://i.ibb.co/MkwVJpJt/giphy-5.gif)

## ✨ Features

- **Fully Customizable UI** - Create beautiful interfaces with various UI components
- **Advanced Theming System** - Choose from built-in themes or create your own
- **Animated Hover Effects** - Enhanced visual feedback with smooth animations
- **Dynamic Icon Library** - 90+ built-in icons organized by categories
- **Responsive Design** - Adapts to different screen sizes and resolutions
- **Mobile Support** - Works on touch devices with appropriate control sizing
- **Home Page** - Optional built-in home page with player and game info
- **Loading Screen** - Customizable loading screen with progress bar
- **Notification System** - Informative notifications with different types

## 📋 Quick Start

Add this to your script to get started:

```lua
local TBD = loadstring(game:HttpGet('https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua'))()

-- Create window
local Window = TBD:CreateWindow({
    Title = "My Script Hub",
    Subtitle = "v1.0",
    Theme = "HoHo",
    ShowHomePage = true
})

-- Create tab with icon
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "Home" -- Use icon name from the dynamic icon library
})

-- Create interactive elements
MainTab:CreateButton({
    Name = "Click Me",
    Callback = function()
        TBD:Notification({
            Title = "Button Clicked",
            Message = "You clicked the button!",
            Duration = 3,
            Type = "Success"
        })
    end
})
```

## 🎮 UI Components

TBD UI Library includes various components for building your interface:

- **Sections** - Organize elements with headers
- **Buttons** - Trigger actions with animated hover effects
- **Toggles** - Enable/disable features
- **Sliders** - Adjust numerical values
- **Dropdowns** - Select from multiple options
- **Inputs** - Text entry fields
- **Keybinds** - Customizable keyboard shortcuts
- **Color Pickers** - Select colors with a visual picker
- **Labels** - Display text information
- **Paragraphs** - Show multi-line text content

## 🎨 New Animated Hover Effects

The Enhanced Edition features sophisticated hover animations:

- **Growth/Shrink Effects** - Elements subtly expand when hovered
- **Color Transitions** - Smooth color changes with theme integration
- **Glow Effects** - Soft glow around elements on hover
- **Text Enhancement** - Text brightness and size changes for better feedback

## 🖼️ Dynamic Icon Library

This version includes an expanded icon library with over 90 built-in icons:

- **UI Essentials** - Home, Settings, Close, etc.
- **Game Elements** - Player, Target, Crown, etc.
- **Actions** - Play, Download, Save, etc.
- **Communication** - Chat, Mail, Phone, etc.
- **Navigation** - Map, Compass, Location, etc.
- **Categories** - Folder, File, Image, etc.
- **Social** - User, Users, AddUser, etc.
- **Devices** - Desktop, Mobile, Tablet, etc.
- **Tools** - Sword, Shield, Key, etc.
- **Weather** - Sun, Cloud, Rain, etc.

Access icons easily with the new GetIcon helper function:

```lua
-- Use icon by name in components
local Tab = Window:CreateTab({
    Name = "Players",
    Icon = "User" -- Simply use the icon name
})

-- Or get the icon ID directly
local iconId = TBD:GetIcon("Home")
```

## 🌈 Themes

Choose from built-in themes or create your own:

```lua
-- Use a built-in theme
TBD:SetTheme("HoHo") -- Default, Midnight, Neon, Aqua, HoHo

-- Create your own theme
TBD:CustomTheme({
    Primary = Color3.fromRGB(20, 20, 20),
    Secondary = Color3.fromRGB(15, 15, 15),
    Background = Color3.fromRGB(10, 10, 10),
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(190, 190, 190),
    Accent = Color3.fromRGB(255, 30, 50),
    DarkAccent = Color3.fromRGB(200, 25, 45)
})
```

## 📱 Responsiveness

TBD UI Library automatically adapts to different screen sizes:

- Adjusts for desktop and mobile screens
- Touch-friendly controls for mobile users
- Proper positioning of dropdowns and color pickers
- Safe area adjustments for notches and system interfaces

## 🔔 Notifications

Show informative notifications to your users:

```lua
TBD:Notification({
    Title = "Success",
    Message = "Operation completed successfully",
    Duration = 5,
    Type = "Success" -- Info, Success, Warning, Error
})
```

## 🏠 Home Page

Enable the built-in home page to show player and game information:

```lua
local Window = TBD:CreateWindow({
    -- other options
    ShowHomePage = true
})
```

## 📘 Documentation

For complete documentation, see the `DOCUMENTATION.md` file for detailed instructions on all library features and components.

## 🧪 Example Script

Check out the `example-tbd.lua` file for a complete example that demonstrates all features of the Enhanced Edition.

## 📝 License

This project is open source and available for use in your scripts.

## 🤝 Contributing

Feel free to contribute to this library by suggesting improvements or reporting issues.

---

Made with ❤️ by TBD Development Team
