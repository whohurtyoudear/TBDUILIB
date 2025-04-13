--[[
    TBD UI Library - Fixed Example (v9)
    This example demonstrates usage of the Type Error Fixed version
]]

-- Load the fixed library from GitHub
local TBD = loadstring(game:HttpGet("https://raw.githubusercontent.com/whohurtyoudear/TBDUILIB/refs/heads/main/tbd.lua"))()

-- Create a window with the same options as before
local Window = TBD:CreateWindow({
    Title = "TBD UI Library",
    Subtitle = "Type Error Fixed Version",
    TabWidth = 160, -- Wider tabs for HoHo style
    Size = UDim2.new(0, 650, 0, 460), -- Wider window (HoHo style)
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
    Icon = "search"
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

-- Add test cases that trigger potential type errors
TestTab:CreateSection("Type Error Tests")

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

-- Test with UICorner radius
TestTab:CreateButton({
    Name = "Create UICorner Test",
    Description = "Tests UICorner with number radius",
    Callback = function()
        -- This would normally trigger an error with numeric radius
        local testFrame = Instance.new("Frame")
        testFrame.Size = UDim2.new(0, 100, 0, 100)
        testFrame.Position = UDim2.new(0.5, -50, 0.5, -50)
        testFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        testFrame.Parent = game.CoreGui
        
        -- This should be fixed now to handle number input
        local corner = Instance.new("UICorner")
        corner.CornerRadius = 8 -- Intentionally using number instead of UDim
        corner.Parent = testFrame
        
        TBD:Notification({
            Title = "UICorner Test",
            Message = "Created frame with UICorner",
            Type = "Success",
            Duration = 3
        })
        
        -- Cleanup after 3 seconds
        task.delay(3, function()
            testFrame:Destroy()
        end)
    end
})

-- Show a welcome notification
TBD:Notification({
    Title = "Welcome!",
    Message = "TBD UI Library v9 has been loaded successfully.",
    Type = "Success",
    Duration = 5
})
