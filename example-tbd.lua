--[[
    TBD UI Library - Enhanced Example Script
    This example demonstrates all features of the enhanced TBD UI Library
]]

-- Load the TBD UI Library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()

-- Create a Window with enhanced options
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v1.1.0",
    Theme = "Aqua", -- Try the new Aqua theme (options: Default, Midnight, Neon, Aqua)
    Size = {500, 550}, -- Automatically adapts for mobile
    Position = "Center",
    LogoId = "12345678", -- Replace with your logo asset ID
    LoadingEnabled = true,
    LoadingTitle = "TBD Script Hub",
    LoadingSubtitle = "Loading awesome features...",
    
    -- Enhanced loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Slide", -- Options: "Fade", "Slide", "Scale"
        LogoSize = UDim2.new(0, 120, 0, 120),
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
        ProgressBarSize = UDim2.new(0.8, 0, 0, 8)
    },
    
    ConfigSettings = {
        ConfigFolder = "TBDScriptHub"
    },
    
    -- Uncomment to enable key system
    --[[
    KeySystem = true,
    KeySettings = {
        Title = "Authentication Required",
        Subtitle = "Key System",
        Note = "Get your key from our Discord server",
        SaveKey = true,
        Keys = {"EXAMPLE-KEY-12345", "PREMIUM-KEY-67890"},
        SecondaryAction = {
            Enabled = true,
            Type = "Discord",
            Parameter = "your-discord-invite-code"
        }
    }
    --]]
})

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
    ImageSource = "Phosphor",
    ShowTitle = true
})

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "person",
    ImageSource = "Phosphor"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "eye",
    ImageSource = "Phosphor"
})

local ThemesTab = Window:CreateTab({
    Name = "Themes",
    Icon = "favorite",
    ImageSource = "Phosphor"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Phosphor"
})

-- Main Tab Elements
MainTab:CreateSection("Welcome")

MainTab:CreateButton({
    Name = "Join Discord",
    Description = "Join our community for updates and support",
    Callback = function()
        -- Implement your Discord invite logic here
        TBD:Notification({
            Title = "Discord Invite",
            Message = "Opening Discord invite link...",
            Type = "Info",
            Duration = 3
        })
        
        -- Example: setclipboard("https://discord.gg/your-invite")
    end
})

-- Show different notification types
local notifyButton = MainTab:CreateButton({
    Name = "Show Notifications",
    Description = "Demonstrate fixed notification system",
    Callback = function()
        -- Success notification
        TBD:Notification({
            Title = "Success",
            Message = "Operation completed successfully!",
            Type = "Success",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Info notification
        TBD:Notification({
            Title = "Information",
            Message = "This is an informational message with details about something important.",
            Type = "Info",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Warning notification
        TBD:Notification({
            Title = "Warning",
            Message = "Please be careful! This action might have consequences.",
            Type = "Warning",
            Duration = 4
        })
        
        -- Wait a moment before showing next notification
        task.wait(1)
        
        -- Error notification
        TBD:Notification({
            Title = "Error",
            Message = "Something went wrong. Please try again later.",
            Type = "Error",
            Duration = 4
        })
    end
})

MainTab:CreateDivider()

MainTab:CreateSection("Script Status")

MainTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents being kicked for inactivity",
    CurrentValue = true,
    Callback = function(Value)
        -- Implement Anti AFK logic
        if Value then
            TBD:Notification({
                Title = "Anti AFK",
                Message = "Anti AFK is now enabled",
                Type = "Success"
            })
            
            -- Your anti-AFK code here
        else
            TBD:Notification({
                Title = "Anti AFK",
                Message = "Anti AFK is now disabled",
                Type = "Info"
            })
            
            -- Disable anti-AFK
        end
    end
}, "AntiAFK")

-- Player Tab Elements
PlayerTab:CreateSection("Character Modifications")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Modify your character's walking speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(Value)
        -- Implement walk speed
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
}, "WalkSpeed")

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Description = "Modify your character's jumping ability",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(Value)
        -- Implement jump power
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
}, "JumpPower")

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Description = "Jump as many times as you want in the air",
    CurrentValue = false,
    Callback = function(Value)
        -- Implement infinite jump
        _G.InfiniteJump = Value
        
        if not _G.InfiniteJumpConnected then
            _G.InfiniteJumpConnected = true
            
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump and 
                   game.Players.LocalPlayer.Character and 
                   game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end
}, "InfiniteJump")

PlayerTab:CreateDivider()

PlayerTab:CreateSection("Player Abilities")

PlayerTab:CreateToggle({
    Name = "Fly",
    Description = "Allows your character to fly",
    CurrentValue = false,
    Callback = function(Value)
        -- Basic fly script implementation
        if Value then
            -- Enable fly
            TBD:Notification({
                Title = "Fly Enabled",
                Message = "Press E to toggle flying, WASD to move",
                Type = "Success"
            })
            
            -- Your fly implementation here
            -- This is a placeholder for actual fly code
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:WaitForChild("Humanoid")
            local torso = character:WaitForChild("HumanoidRootPart")
            
            -- Note: This is a simplified example, a real fly script would be more complex
            _G.Flying = false
            
            -- Actual fly code would go here
        else
            -- Disable fly
            TBD:Notification({
                Title = "Fly Disabled",
                Message = "Flying has been disabled",
                Type = "Info"
            })
            
            -- Disable fly implementation
            _G.Flying = false
        end
    end
}, "Fly")

-- Visuals Tab Elements
VisualsTab:CreateSection("ESP Settings")

VisualsTab:CreateToggle({
    Name = "Player ESP",
    Description = "See players through walls",
    CurrentValue = false,
    Callback = function(Value)
        -- Implement ESP
        _G.PlayerESP = Value
        
        if Value then
            TBD:Notification({
                Title = "ESP Enabled",
                Message = "Player ESP is now active",
                Type = "Success"
            })
            
            -- Your ESP implementation here
        else
            TBD:Notification({
                Title = "ESP Disabled",
                Message = "Player ESP is now inactive",
                Type = "Info"
            })
            
            -- Disable ESP
        end
    end
}, "PlayerESP")

VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Description = "Change the color of ESP highlights",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        -- Update ESP color
        _G.ESPColor = Color
    end
}, "ESPColor")

VisualsTab:CreateDivider()

VisualsTab:CreateSection("Game Visuals")

VisualsTab:CreateToggle({
    Name = "Full Bright",
    Description = "Makes the game fully bright",
    CurrentValue = false,
    Callback = function(Value)
        -- Implement full bright
        if Value then
            -- Enable full bright
            _G.OriginalBrightness = game:GetService("Lighting").Brightness
            _G.OriginalAmbient = game:GetService("Lighting").Ambient
            
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").GlobalShadows = false
        else
            -- Disable full bright
            if _G.OriginalBrightness then
                game:GetService("Lighting").Brightness = _G.OriginalBrightness
                game:GetService("Lighting").Ambient = _G.OriginalAmbient
                game:GetService("Lighting").GlobalShadows = true
            end
        end
    end
}, "FullBright")

VisualsTab:CreateSlider({
    Name = "Field of View",
    Description = "Adjust camera field of view",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(Value)
        -- Implement FOV changer
        if game:GetService("Workspace").CurrentCamera then
            game:GetService("Workspace").CurrentCamera.FieldOfView = Value
        end
    end
}, "FieldOfView")

-- Themes Tab Elements - Showcasing the new theme features
ThemesTab:CreateSection("UI Themes")

ThemesTab:CreateDropdown({
    Name = "Select Theme",
    Description = "Choose a pre-built theme for the UI",
    Items = {"Default", "Midnight", "Neon", "Aqua"}, -- Added new Aqua theme
    Default = "Aqua",
    Callback = function(Theme)
        TBD:SetTheme(Theme)
        
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. Theme .. " theme",
            Type = "Success"
        })
    end
}, "UITheme")

ThemesTab:CreateColorPicker({
    Name = "Primary Color",
    Description = "Change the main accent color",
    Color = Color3.fromRGB(0, 210, 255), -- Default Aqua primary color
    Callback = function(Color)
        -- Apply just the primary color change
        TBD:CustomTheme({
            Primary = Color,
            PrimaryDark = Color:Lerp(Color3.new(0, 0, 0), 0.2) -- Automatically create a darker version
        })
    end
}, "PrimaryColor")

ThemesTab:CreateSlider({
    Name = "UI Transparency",
    Description = "Adjust the transparency of the UI",
    Range = {0, 90},
    Increment = 5,
    CurrentValue = 5,
    Callback = function(Value)
        -- Calculate transparency (0-1 range)
        local transparency = Value / 100
        
        -- Apply transparency
        TBD:CustomTheme({
            Transparency = 1 - transparency -- Convert to the format the library expects
        })
    end
}, "UITransparency")

ThemesTab:CreateDropdown({
    Name = "Icon Pack",
    Description = "Choose which icon style to use",
    Items = {"Material", "Phosphor"},
    Default = "Phosphor",
    Callback = function(Pack)
        -- Change icon pack
        TBD:CustomTheme({
            IconPack = Pack
        })
        
        TBD:Notification({
            Title = "Icon Pack Changed",
            Message = "Applied the " .. Pack .. " icon pack. Changes will appear when reopening the UI.",
            Type = "Info"
        })
    end
}, "IconPack")

ThemesTab:CreateToggle({
    Name = "Drop Shadows",
    Description = "Toggle UI element shadows",
    CurrentValue = true,
    Callback = function(Value)
        -- Toggle drop shadows
        TBD:CustomTheme({
            DropShadowEnabled = Value
        })
    end
}, "DropShadows")

ThemesTab:CreateDivider()

ThemesTab:CreateSection("Custom Theme")

ThemesTab:CreateButton({
    Name = "Create Random Theme",
    Description = "Generate a random color theme",
    Callback = function()
        -- Generate random colors
        local primary = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        local background = Color3.fromRGB(math.random(10, 30), math.random(10, 30), math.random(10, 30))
        
        -- Apply random theme
        TBD:CustomTheme({
            Primary = primary,
            PrimaryDark = primary:Lerp(Color3.new(0, 0, 0), 0.2),
            Background = background,
            ContainerBackground = background:Lerp(Color3.new(1, 1, 1), 0.1),
            SecondaryBackground = background:Lerp(Color3.new(1, 1, 1), 0.2),
            ElementBackground = background:Lerp(Color3.new(1, 1, 1), 0.3)
        })
        
        TBD:Notification({
            Title = "Random Theme Applied",
            Message = "Created a unique random theme!",
            Type = "Success"
        })
    end
})

-- Settings Tab Elements
SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateDropdown({
    Name = "Notification Position",
    Description = "Where notifications appear on screen",
    Items = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"},
    Default = "TopRight",
    Callback = function(Position)
        -- Set notification position
        NotificationSystem:SetPosition(Position)
        
        TBD:Notification({
            Title = "Position Updated",
            Message = "Notifications will now appear in the " .. Position .. " position",
            Type = "Info"
        })
    end
}, "NotificationPosition")

SettingsTab:CreateSlider({
    Name = "Notification Duration",
    Description = "How long notifications remain on screen (seconds)",
    Range = {1, 10},
    Increment = 0.5,
    CurrentValue = 5,
    Callback = function(Value)
        -- Update notification duration
        NotificationSystem.DefaultDuration = Value
        
        TBD:Notification({
            Title = "Duration Updated",
            Message = "Notifications will now display for " .. Value .. " seconds",
            Type = "Info",
            Duration = Value -- Apply the new duration immediately
        })
    end
}, "NotificationDuration")

SettingsTab:CreateDivider()

SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
    Name = "Save Configuration",
    Description = "Save current settings to a file",
    Callback = function()
        -- Implement save logic with a name input
        local configName = "DefaultConfig"
        TBD:SaveConfig(configName)
        
        TBD:Notification({
            Title = "Configuration Saved",
            Message = "Saved settings as " .. configName,
            Type = "Success"
        })
    end
})

SettingsTab:CreateButton({
    Name = "Reset All Settings",
    Description = "Reset all settings to default values",
    Callback = function()
        -- Reset all settings
        
        -- Reset player settings
        WalkSpeedSlider:Set(16)
        JumpPowerSlider:Set(50)
        
        -- Apply to character
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        
        TBD:Notification({
            Title = "Settings Reset",
            Message = "All settings have been reset to defaults",
            Type = "Info"
        })
    end
})

SettingsTab:CreateDivider()

SettingsTab:CreateSection("Script Management")

SettingsTab:CreateButton({
    Name = "Unload Script",
    Description = "Completely remove the script from the game",
    Callback = function()
        TBD:Notification({
            Title = "Unloading Script",
            Message = "Goodbye! The script will now unload",
            Type = "Info"
        })
        
        -- Wait for notification to show
        task.wait(1)
        
        -- Reset character to default settings
        if game.Players.LocalPlayer.Character and 
           game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        
        -- Reset camera FOV
        if game:GetService("Workspace").CurrentCamera then
            game:GetService("Workspace").CurrentCamera.FieldOfView = 70
        end
        
        -- Reset lighting
        if _G.OriginalBrightness then
            game:GetService("Lighting").Brightness = _G.OriginalBrightness
            game:GetService("Lighting").Ambient = _G.OriginalAmbient
            game:GetService("Lighting").GlobalShadows = true
        end
        
        -- Disable all global settings
        _G.InfiniteJump = false
        _G.PlayerESP = false
        _G.Flying = false
        
        -- Unload the UI
        TBD:Destroy()
    end
})

-- Load auto-save config at the end of the script
TBD:LoadAutoloadConfig()
