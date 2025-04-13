--[[
    TBD UI Library - V10 Example
    This example demonstrates all the features and fixes in V10
]]

-- Load the library from GitHub or use local source
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua"))()

-- Create a window
local Window = TBD:CreateWindow({
    Title = "TBD UI Library",
    Subtitle = "V10 Fixed Edition",
    TabWidth = 160, -- Wider tabs for HoHo style
    Size = 650, -- Can now use a number directly, will be auto-converted to UDim2
    Theme = "HoHo", -- Use HoHo theme by default
    MinimizeKey = Enum.KeyCode.LeftAlt,
    ShowHomePage = true -- Show the home page with player info
})

-- Create tabs
local GeneralTab = Window:CreateTab({
    Name = "General",
    Icon = "settings"
})

local TestTab = Window:CreateTab({
    Name = "Test Cases",
    Icon = "flask"
})

-- Add elements to General tab
GeneralTab:CreateSection("Basic Controls")

-- Create a button
GeneralTab:CreateButton({
    Name = "Simple Button",
    Description = "Click to perform an action",
    Callback = function()
        TBD:Notification({
            Title = "Button Clicked",
            Message = "You clicked the button!",
            Type = "Info",
            Duration = 3
        })
    end
})

-- Create a toggle
GeneralTab:CreateToggle({
    Name = "Feature Toggle",
    Description = "Enable or disable a feature",
    CurrentValue = false,
    Flag = "featureEnabled",
    Callback = function(value)
        print("Toggle switched to:", value)
    end
})

-- Create a slider
GeneralTab:CreateSlider({
    Name = "Speed Adjustment",
    Description = "Adjust the speed value",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Flag = "speedValue",
    Callback = function(value)
        print("Slider value changed to:", value)
    end
})

-- Create a dropdown
GeneralTab:CreateDropdown({
    Name = "Select Option",
    Description = "Choose from available options",
    Items = {"Option 1", "Option 2", "Option 3", "Option 4"},
    CurrentOption = "Option 1",
    Flag = "selectedOption",
    Callback = function(option)
        print("Selected option:", option)
    end
})

-- Add test cases that demonstrate the type safety fixes
TestTab:CreateSection("Type Error Fixes")

-- Test with number as string
TestTab:CreateButton({
    Name = 123, -- Intentionally using a number instead of string
    Description = "Testing number as name",
    Callback = function()
        TBD:Notification({
            Title = 456, -- Intentionally using a number
            Message = 789, -- Intentionally using a number
            Type = "Info",
            Duration = 3
        })
    end
})

-- UICorner with number radius
TestTab:CreateButton({
    Name = "Test UICorner",
    Description = "Test UICorner with number radius",
    Callback = function()
        -- Create a test frame
        local testFrame = Instance.new("Frame")
        testFrame.Size = UDim2.new(0, 200, 0, 200)
        testFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
        testFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        testFrame.Parent = game.CoreGui
        
        -- This would normally cause an error without the type safety fix:
        local corner = Instance.new("UICorner")
        corner.CornerRadius = 8 -- Using a number instead of UDim
        corner.Parent = testFrame
        
        TBD:Notification({
            Title = "UICorner Test",
            Message = "Created frame with number radius - should work with type safety!",
            Type = "Success",
            Duration = 5
        })
        
        -- Cleanup after 5 seconds
        task.delay(5, function()
            testFrame:Destroy()
        end)
    end
})

-- Test Color Picker with both naming conventions
TestTab:CreateButton({
    Name = "Test Color Picker Names",
    Description = "Test both ColorPicker and Colorpicker",
    Callback = function()
        -- Both these methods should work due to our compatibility fix
        local picker1 = TestTab:CreateColorPicker({
            Name = "Method 1",
            Default = Color3.fromRGB(255, 0, 0),
            Callback = function(color) end
        })
        
        local picker2 = TestTab:CreateColorpicker({
            Name = "Method 2",
            Default = Color3.fromRGB(0, 255, 0),
            Callback = function(color) end
        })
        
        TBD:Notification({
            Title = "Color Picker Test",
            Message = "Both naming conventions work!",
            Type = "Success",
            Duration = 3
        })
    end
})

-- Test Window Size with all formats
TestTab:CreateButton({
    Name = "Test Window Size",
    Description = "Test different window size formats",
    Callback = function()
        -- Create windows with different size formats
        local window1 = TBD:CreateWindow({
            Title = "UDim2 Size",
            Size = UDim2.new(0, 500, 0, 300),
            Position = UDim2.new(0, 100, 0, 100)
        })
        
        local window2 = TBD:CreateWindow({
            Title = "Table Size",
            Size = {400, 250},
            Position = UDim2.new(0, 100, 0, 450)
        })
        
        local window3 = TBD:CreateWindow({
            Title = "Number Size",
            Size = 300, -- Single number
            Position = UDim2.new(0, 600, 0, 100)
        })
        
        TBD:Notification({
            Title = "Window Size Test",
            Message = "Created windows with all size formats!",
            Type = "Success", 
            Duration = 3
        })
        
        -- Cleanup after 5 seconds
        task.delay(5, function()
            window1:Destroy()
            window2:Destroy()
            window3:Destroy()
        end)
    end
})

-- Welcome notification
TBD:Notification({
    Title = "V10 Fixed Edition",
    Message = "TBD UI Library loaded successfully with all type safety fixes!",
    Type = "Success",
    Duration = 5
})
