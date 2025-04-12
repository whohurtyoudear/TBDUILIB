--[[
    TBD UI Library - HoHo Edition Example (v5)
    This example demonstrates all features of the redesigned TBD UI Library
    with fixes for dropdown and color picker issues
]]

-- Load the TBD UI Library
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua", true))()

-- Create a Window with enhanced options
local Window = TBD:CreateWindow({
    Title = "TBD Script Hub",
    Subtitle = "v2.0.0 HoHo Edition",
    Theme = "HoHo", -- Try the new HoHo theme (options: Default, Midnight, Neon, Aqua, HoHo)
    Size = {780, 460}, -- Wider layout as requested
    Position = "Center",
    LogoId = "rbxassetid://140132696023344", -- Example logo asset ID
    LoadingEnabled = true,
    LoadingTitle = "TBD Script Hub",
    LoadingSubtitle = "Loading awesome features...",
    
    -- Enable the home page feature that shows player info
    ShowHomePage = true,
    
    -- Enhanced loading screen customization
    LoadingScreenCustomization = {
        AnimationStyle = "Slide", -- Options: "Fade", "Slide", "Scale"
        LogoSize = UDim2.new(0, 120, 0, 120),
        LogoPosition = UDim2.new(0.5, 0, 0.35, 0),
        ProgressBarSize = UDim2.new(0.7, 0, 0, 6)
    }
})

-- The Home tab is automatically created when ShowHomePage is true
-- You can access it with Window.HomeTab if you need to add custom elements
Window.HomeTab:CreateButton({
    Name = "Join Discord",
    Description = "Join our community for updates and support",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/yourdiscord") end)
        TBD:Notification({
            Title = "Discord Invite",
            Message = "Discord invite link copied to clipboard!",
            Type = "Success",
            Duration = 3
        })
    end
})

-- Create Tabs
local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "home"
})

local PlayerTab = Window:CreateTab({
    Name = "Player",
    Icon = "person"
})

local VisualsTab = Window:CreateTab({
    Name = "Visuals",
    Icon = "eye"
})

local ThemesTab = Window:CreateTab({
    Name = "Themes",
    Icon = "favorite"
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings"
})

-- Fix position of notifications
TBD.NotificationSystem:SetPosition("TopRight")

-- Main Tab Elements
MainTab:CreateSection("Welcome")

MainTab:CreateButton({
    Name = "Show Notification",
    Description = "Display a sample notification",
    Callback = function()
        TBD:Notification({
            Title = "Welcome",
            Message = "TBD UI Library has been loaded successfully!",
            Type = "Success",
            Duration = 5
        })
    end
})

-- Show different notification types
local notifyButton = MainTab:CreateButton({
    Name = "Show All Notifications",
    Description = "Demonstrate notification system",
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

-- Demonstrating the fixed CreateToggle function
MainTab:CreateToggle({
    Name = "Anti AFK",
    Description = "Prevents being kicked for inactivity",
    CurrentValue = true,
    Flag = "AntiAFK", -- Flag for saving in config
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
})

-- Testing the fixed CreateSlider function
MainTab:CreateSlider({
    Name = "Music Volume",
    Description = "Adjust the background music volume",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Flag = "MusicVolume",
    Callback = function(Value)
        print("Music Volume:", Value)
    end
})

-- Player Tab Elements
PlayerTab:CreateSection("Character Modifications")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Description = "Modify your character's walking speed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed", -- Flag for saving in config
    Callback = function(Value)
        -- Implement walk speed
        pcall(function()
            if game.Players.LocalPlayer.Character and 
            game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
            end
        end)
    end
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Description = "Modify your character's jumping ability",
    Range = {50, 500},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPower", -- Flag for saving in config
    Callback = function(Value)
        -- Implement jump power
        pcall(function()
            if game.Players.LocalPlayer.Character and 
            game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
            end
        end)
    end
})

-- Another example of CreateToggle usage
PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Description = "Jump as many times as you want in the air",
    CurrentValue = false,
    Flag = "InfiniteJump", -- Flag for saving in config
    Callback = function(Value)
        -- Implement infinite jump
        _G.InfiniteJump = Value
        
        if not _G.InfiniteJumpConnected then
            _G.InfiniteJumpConnected = true
            
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if _G.InfiniteJump and 
                   game.Players.LocalPlayer.Character and 
                   game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    pcall(function()
                        game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            end)
        end
    end
})

-- Demonstrate fixed dropdown feature
PlayerTab:CreateDropdown({
    Name = "Select Team",
    Description = "Choose which team to join",
    Items = {"Red Team", "Blue Team", "Green Team", "Yellow Team", "No Team"},
    Default = "No Team",
    Flag = "SelectedTeam",
    Callback = function(Team)
        TBD:Notification({
            Title = "Team Selected",
            Message = "You selected: " .. Team,
            Type = "Info"
        })
    end
})

-- Demonstrate text input
PlayerTab:CreateTextbox({
    Name = "Custom Player Name",
    Description = "Set a custom name (visual only)",
    PlaceholderText = "Enter name...",
    Text = "",
    CharacterLimit = 16,
    Flag = "CustomName",
    Callback = function(Text)
        TBD:Notification({
            Title = "Name Changed",
            Message = "Set custom name to: " .. Text,
            Type = "Success"
        })
    end
})

-- Visuals Tab Elements
VisualsTab:CreateSection("Visual Options")

VisualsTab:CreateToggle({
    Name = "ESP",
    Description = "See players through walls",
    CurrentValue = false,
    Callback = function(Value)
        TBD:Notification({
            Title = "ESP",
            Message = Value and "ESP enabled" or "ESP disabled",
            Type = Value and "Success" or "Info"
        })
    end
})

VisualsTab:CreateToggle({
    Name = "Tracers",
    Description = "Draw lines to players",
    CurrentValue = false,
    Callback = function(Value)
        TBD:Notification({
            Title = "Tracers",
            Message = Value and "Tracers enabled" or "Tracers disabled",
            Type = Value and "Success" or "Info"
        })
    end
})

-- Demonstrating fixed color picker
VisualsTab:CreateColorPicker({
    Name = "ESP Color",
    Description = "Change the color of ESP elements",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(Color)
        TBD:Notification({
            Title = "ESP Color",
            Message = "ESP color updated",
            Type = "Success"
        })
    end
})

VisualsTab:CreateDropdown({
    Name = "ESP Style",
    Description = "Select the style of ESP to use",
    Items = {"Box", "Name", "Box + Name", "Box + Name + Health", "Custom"},
    Default = "Box",
    Flag = "ESPStyle",
    Callback = function(Style)
        TBD:Notification({
            Title = "ESP Style",
            Message = "Set ESP style to: " .. Style,
            Type = "Info"
        })
    end
})

-- Themes Tab Elements - Showcasing the theme system
ThemesTab:CreateSection("UI Themes")

-- Fixed dropdown for theme selection
ThemesTab:CreateDropdown({
    Name = "Select Theme",
    Description = "Choose a pre-built theme for the UI",
    Items = {"Default", "Midnight", "Neon", "Aqua", "HoHo"}, -- Added new HoHo theme
    Default = "HoHo",
    Flag = "UITheme", -- Flag for saving in config
    Callback = function(Theme)
        TBD:SetTheme(Theme)
        
        TBD:Notification({
            Title = "Theme Changed",
            Message = "Applied the " .. Theme .. " theme",
            Type = "Success"
        })
    end
})

-- Fixed color picker for custom accent color
ThemesTab:CreateColorPicker({
    Name = "Custom Accent Color",
    Description = "Set a custom accent color for the UI",
    Color = Color3.fromRGB(255, 30, 50), -- Default HoHo accent
    Callback = function(Color)
        TBD:CustomTheme({
            Accent = Color,
            DarkAccent = Color3.new(
                math.clamp(Color.R - 0.2, 0, 1),
                math.clamp(Color.G - 0.2, 0, 1),
                math.clamp(Color.B - 0.2, 0, 1)
            )
        })
        
        TBD:Notification({
            Title = "Custom Color",
            Message = "Custom accent color applied",
            Type = "Success"
        })
    end
})

-- Settings Tab Elements
SettingsTab:CreateSection("UI Settings")

-- Fixed dropdown for notification position
SettingsTab:CreateDropdown({
    Name = "Notification Position",
    Description = "Where notifications appear on screen",
    Items = {"TopRight", "TopLeft", "BottomRight", "BottomLeft"},
    Default = "TopRight",
    Flag = "NotificationPosition", -- Flag for saving in config
    Callback = function(Position)
        -- Set notification position
        TBD.NotificationSystem:SetPosition(Position)
        
        TBD:Notification({
            Title = "Position Updated",
            Message = "Notifications will now appear in the " .. Position .. " position",
            Type = "Info"
        })
    end
})

SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    Description = "Key to show/hide the interface",
    CurrentKeybind = "RightShift",
    Flag = "ToggleUI",
    Callback = function(Key)
        TBD:Notification({
            Title = "Toggle Key",
            Message = "UI toggle key set to " .. Key,
            Type = "Info"
        })
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Description = "Permanently remove the interface",
    Callback = function()
        TBD:Notification({
            Title = "Destroying UI",
            Message = "Interface will be destroyed in 3 seconds",
            Type = "Warning",
            Duration = 3
        })
        
        task.delay(3, function()
            Window:Destroy()
        end)
    end
})

-- Hide/Show UI functionality with keybind
local function toggleUI()
    if Window.MainFrame.Visible then
        Window:Minimize()
    else
        Window:Expand()
    end
end

-- Setup global keyboard toggle
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local keyName = "None"
    if input.UserInputType == Enum.UserInputType.Keyboard then
        keyName = string.sub(tostring(input.KeyCode), 14)
    end
    
    if keyName == TBD.Flags["ToggleUI"] or keyName == "RightShift" then
        toggleUI()
    end
end)

-- Print a message to confirm the UI has loaded completely
print("TBD UI Library v5 loaded successfully!")
