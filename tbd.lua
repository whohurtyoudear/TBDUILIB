--[[
    TBD UI Library
    
    A comprehensive Lua-based UI library for Roblox with an 80s retro aesthetic theme
    Created with cross-executor compatibility in mind
    
    Features:
    - Sleek 80s Retro Design with VHS aesthetics
    - Comprehensive UI Components
    - Smooth Animations and Transitions
    - Universal Compatibility with all Roblox executors/injectors
    - Easy Implementation with intuitive API
    - Fully Customizable theme and settings
    - Responsive Layout and automatic sizing
    
    Version: 1.0.0
]]

------------------------
-- COMPATIBILITY LAYER
------------------------
-- Check if running outside of Roblox and create necessary globals
if not game then
    print("[TBD UI Lib] Running in test mode outside of Roblox")
    
    -- Create basic Lua types if they don't exist
    if not typeof then
        typeof = type
    end
    
    -- Create a minimal mock game object
    game = {
        GetService = function(self, serviceName)
            return {
                Players = {
                    LocalPlayer = {
                        PlayerGui = {},
                        Character = {
                            Humanoid = {
                                WalkSpeed = 16,
                                JumpPower = 50
                            }
                        },
                        GetMouse = function() return {X=0, Y=0} end
                    },
                    GetPlayers = function() return {} end
                },
                RunService = {
                    RenderStepped = {
                        Connect = function() return {Disconnect = function() end} end
                    }
                },
                UserInputService = {
                    InputBegan = {
                        Connect = function() return {Disconnect = function() end} end
                    },
                    InputEnded = {
                        Connect = function() return {Disconnect = function() end} end
                    },
                    GetMouseLocation = function() return {X=0, Y=0} end
                },
                TweenService = {
                    Create = function() return {Play = function() end} end
                },
                HttpService = {
                    JSONEncode = function(_, data) return "" end,
                    JSONDecode = function(_, json) return {} end
                },
                TextService = {
                    GetTextSize = function() return {X=100, Y=20} end
                }
            }
        end,
        HttpGet = function() return "" end
    }
    
    -- Create Vector2/3 classes
    if not Vector2 then
        Vector2 = {
            new = function(x, y)
                return {X = x or 0, Y = y or 0}
            end
        }
    end
    
    if not Vector3 then
        Vector3 = {
            new = function(x, y, z)
                return {X = x or 0, Y = y or 0, Z = z or 0}
            end
        }
    end
    
    -- Create UDim and UDim2 classes
    if not UDim then
        UDim = {
            new = function(scale, offset)
                return {Scale = scale or 0, Offset = offset or 0}
            end
        }
    end
    
    if not UDim2 then
        UDim2 = {
            new = function(xScale, xOffset, yScale, yOffset)
                return {
                    X = {Scale = xScale or 0, Offset = xOffset or 0},
                    Y = {Scale = yScale or 0, Offset = yOffset or 0}
                }
            end
        }
    end
    
    -- Create Color3 class
    if not Color3 then
        Color3 = {
            fromRGB = function(r, g, b)
                return {R = r/255, G = g/255, B = b/255}
            end,
            new = function(r, g, b)
                return {R = r, G = g, B = b}
            end
        }
    end
    
    -- Create TweenInfo class
    if not TweenInfo then
        TweenInfo = {
            new = function() return {} end
        }
    end
    
    -- Create Enum class with common values
    if not Enum then
        Enum = {
            KeyCode = {
                Unknown = "Unknown",
                RightShift = "RightShift", 
                LeftShift = "LeftShift",
                E = "E", F = "F"
            },
            EasingStyle = {Quad = "Quad", Linear = "Linear"},
            EasingDirection = {Out = "Out", In = "In", InOut = "InOut"},
            TextXAlignment = {Left = "Left", Right = "Right", Center = "Center"},
            TextYAlignment = {Top = "Top", Bottom = "Bottom", Center = "Center"},
            Font = {Gotham = "Gotham", GothamBold = "GothamBold", Arial = "Arial"},
            HorizontalAlignment = {Center = "Center", Left = "Left", Right = "Right"},
            VerticalAlignment = {Center = "Center", Top = "Top", Bottom = "Bottom"},
            SortOrder = {LayoutOrder = "LayoutOrder", Name = "Name"},
            ScrollingDirection = {X = "X", Y = "Y", XY = "XY"},
            AutomaticSize = {X = "X", Y = "Y", XY = "XY", None = "None"},
            ZIndexBehavior = {Sibling = "Sibling", Global = "Global"},
            ScaleType = {Slice = "Slice", Stretch = "Stretch", Tile = "Tile"},
            UserInputType = {
                MouseButton1 = "MouseButton1", 
                MouseButton2 = "MouseButton2",
                MouseMovement = "MouseMovement",
                MouseWheel = "MouseWheel",
                Touch = "Touch",
                Keyboard = "Keyboard"
            },
            HumanoidStateType = {
                Jumping = "Jumping",
                Seated = "Seated",
                Running = "Running"
            }
        }
    end
    
    -- Create Instance class
    if not Instance then
        Instance = {
            new = function(className)
                local instance = {
                    ClassName = className,
                    Name = "",
                    Parent = nil,
                    Position = UDim2.new(),
                    Size = UDim2.new(),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "",
                    TextColor3 = Color3.fromRGB(0, 0, 0),
                    Font = Enum.Font.Gotham,
                    TextSize = 14,
                    ZIndex = 1,
                    Children = {},
                    Connections = {},
                    
                    Destroy = function(self)
                        self.Parent = nil
                        for _, connection in pairs(self.Connections) do
                            if connection.Disconnect then
                                connection:Disconnect()
                            end
                        end
                    end,
                    
                    -- Add a child to this instance
                    AddChild = function(self, child)
                        table.insert(self.Children, child)
                        child.Parent = self
                    end,
                    
                    -- Find a child by name
                    FindFirstChild = function(self, name)
                        for _, child in pairs(self.Children) do
                            if child.Name == name then
                                return child
                            end
                        end
                        return nil
                    end,
                    
                    -- Clone this instance
                    Clone = function(self)
                        local newInstance = Instance.new(self.ClassName)
                        for k, v in pairs(self) do
                            if k ~= "Children" and k ~= "Connections" and type(v) ~= "function" then
                                newInstance[k] = v
                            end
                        end
                        return newInstance
                    end,
                    
                    -- Get all children
                    GetChildren = function(self)
                        return self.Children
                    end,
                    
                    -- Check if this is a specific class
                    IsA = function(self, className)
                        return self.ClassName == className
                    end,
                    
                    -- Clear all children
                    ClearAllChildren = function(self)
                        for _, child in pairs(self.Children) do
                            child:Destroy()
                        end
                        self.Children = {}
                    end,
                    
                    -- For events
                    MouseEnter = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    },
                    MouseLeave = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    },
                    MouseButton1Click = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    },
                    InputBegan = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    },
                    InputEnded = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    },
                    FocusLost = {
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    }
                }
                
                -- Add special properties based on class
                if className == "Sound" then
                    instance.Volume = 1
                    instance.PlaybackSpeed = 1
                    instance.SoundId = ""
                    instance.Playing = false
                    instance.Loaded = {
                        Wait = function() return true end
                    }
                    instance.Ended = {
                        Wait = function() return true end,
                        Connect = function(_, callback)
                            local connection = {Disconnect = function() end}
                            return connection
                        end
                    }
                    instance.Play = function(self)
                        self.Playing = true
                    end
                    instance.Stop = function(self)
                        self.Playing = false
                    end
                end
                
                -- Set __index metamethod to access properties
                setmetatable(instance, {
                    __index = function(t, key)
                        if rawget(t, key) ~= nil then
                            return rawget(t, key)
                        end
                        
                        -- For event connections
                        if key:match("Changed$") or key:match("Event$") then
                            return {
                                Connect = function(_, callback)
                                    local connection = {Disconnect = function() end}
                                    return connection
                                end
                            }
                        end
                        
                        -- For TextBounds (used in UI calculations)
                        if key == "TextBounds" then
                            return {X = string.len(t.Text) * (t.TextSize / 2), Y = t.TextSize}
                        end
                        
                        -- For AbsoluteSize/Position (used in UI calculations)
                        if key == "AbsoluteSize" then
                            return {X = t.Size.X.Offset, Y = t.Size.Y.Offset}
                        end
                        
                        if key == "AbsolutePosition" then
                            return {X = t.Position.X.Offset, Y = t.Position.Y.Offset}
                        end
                        
                        return nil
                    end
                })
                
                return instance
            end
        }
    end
    
    -- Create Rect class
    if not Rect then
        Rect = {
            new = function(x1, y1, x2, y2)
                return {
                    Min = {X = x1, Y = y1},
                    Max = {X = x2, Y = y2},
                    Width = x2 - x1,
                    Height = y2 - y1
                }
            end
        }
    end
    
    -- Create spawn and wait functions
    if not spawn then
        spawn = function(f)
            local co = coroutine.create(f)
            coroutine.resume(co)
            return co
        end
    end
    
    if not wait then
        wait = function(seconds)
            seconds = seconds or 0.03  -- Default wait time
            local start = os.time()
            while os.time() - start < seconds do
                -- Nothing, just waiting
            end
            return seconds
        end
    end
    
    -- Create tick function
    if not tick then
        tick = function()
            return os.time()
        end
    end
    
    -- Create math.clamp if it doesn't exist
    if not math.clamp then
        math.clamp = function(x, min, max)
            return math.min(math.max(x, min), max)
        end
    end
    
    -- Create math.round if it doesn't exist
    if not math.round then
        math.round = function(x)
            return math.floor(x + 0.5)
        end
    end
    
    print("[TBD UI Lib] Compatibility layer initialized")
end

------------------------
-- SERVICES & UTILITIES
------------------------
-- Safe service getter for cross-executor compatibility
local function SafeGetService(serviceName)
    local success, service = pcall(function()
        return game:GetService(serviceName)
    end)
    if success then
        return service
    else
        return {}
    end
end

-- Get CoreGui with fallback
local CoreGui = (function()
    -- In test mode, create a placeholder
    if not game.Players or typeof(game.Players) ~= "table" then
        local placeholder = Instance.new("Folder")
        placeholder.Name = "CoreGuiPlaceholder"
        return placeholder
    end
    
    -- Try to get CoreGui (works in most exploits)
    local success, result = pcall(function()
        return game:GetService("CoreGui")
    end)
    
    if success then
        return result
    else
        -- Fall back to PlayerGui if CoreGui is not accessible
        local players = game:GetService("Players")
        if players and players.LocalPlayer then
            return players.LocalPlayer:WaitForChild("PlayerGui")
        else
            -- Last resort - create a placeholder
            local placeholder = Instance.new("Folder")
            placeholder.Name = "CoreGuiPlaceholder"
            return placeholder
        end
    end
end)()

-- Get services
local TweenService = SafeGetService("TweenService")
local UserInputService = SafeGetService("UserInputService")
local RunService = SafeGetService("RunService")
local TextService = SafeGetService("TextService")
local Players = SafeGetService("Players")
local HttpService = SafeGetService("HttpService")
local LocalPlayer = Players and Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- Constants
local TWEEN_INFO = TweenInfo and TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or {}
local SEPARATOR_THICKNESS = 2
local CORNER_RADIUS = UDim and UDim.new(0, 6) or {Scale = 0, Offset = 6}
local SECTION_SPACING = 10
local HEADER_SIZE = 32
local TAB_HEIGHT = 30
local ELEMENT_HEIGHT = 36

-- Sound IDs that are known to work in Roblox
local SOUNDS = {
    Click = "rbxassetid://6895079853", -- Verified working click sound
    Hover = "rbxassetid://6895079816", -- Verified working hover sound
    Toggle = "rbxassetid://6895079727", -- Verified working toggle sound
    Notification = "rbxassetid://4590657391" -- Verified working notification sound
}

-- Utility Functions
local function SafePlaySound(soundId)
    if not soundId then return end
    
    local success, sound = pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound.Parent = CoreGui
        return sound
    end)
    
    if success then
        pcall(function()
            sound:Play()
            
            -- Clean up sound instance
            spawn(function()
                if sound.IsLoaded then
                    sound.Ended:Wait()
                else
                    sound.Loaded:Wait()
                    sound:Play()
                    sound.Ended:Wait()
                end
                sound:Destroy()
            end)
        end)
    end
end

local function CreateSignal()
    local connections = {}
    
    local function Connect(func)
        table.insert(connections, func)
        
        return {
            Disconnect = function()
                for i, connection in pairs(connections) do
                    if connection == func then
                        table.remove(connections, i)
                        break
                    end
                end
            end
        }
    end
    
    local function Fire(...)
        for _, func in pairs(connections) do
            pcall(func, ...)
        end
    end
    
    return {
        Connect = Connect,
        Fire = Fire
    }
end

local function Tween(instance, properties)
    if TweenService and typeof(TweenService) == "table" and TweenService.Create then
        pcall(function()
            local tween = TweenService:Create(instance, TWEEN_INFO, properties)
            tween:Play()
            return tween
        end)
    else
        -- Fallback for when TweenService is not available
        for property, value in pairs(properties) do
            pcall(function()
                instance[property] = value
            end)
        end
    end
end

local function GetTextSize(text, size, font)
    if TextService and typeof(TextService) == "table" and TextService.GetTextSize then
        local success, result = pcall(function()
            return TextService:GetTextSize(text, size, font, Vector2.new(math.huge, math.huge))
        end)
        if success then 
            return result
        end
    end
    
    -- Approximate if TextService is not available
    return Vector2.new(string.len(text) * (size / 3), size)
end

local function setclipboard(text)
    -- Safe implementation that works across executors
    if writefile and makefolder and isfolder then
        pcall(function()
            if not isfolder("tbd_clipboard") then
                makefolder("tbd_clipboard")
            end
            writefile("tbd_clipboard/clipboard.txt", text)
        end)
    end
    
    -- Try traditional methods too
    pcall(function()
        if Clipboard and Clipboard.set then
            Clipboard.set(text)
        elseif setclipboard then
            setclipboard(text)
        end
    end)
end

------------------------
-- MAIN LIBRARY
------------------------
local T = {
    Flags = {}, -- Will store toggle/slider/dropdown values by their flag name
    Windows = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 15),
        Accent = Color3.fromRGB(255, 0, 60), -- Primary color (neon red)
        SecondaryAccent = Color3.fromRGB(0, 170, 255), -- Secondary color (neon blue)
        LightContrast = Color3.fromRGB(30, 30, 30),
        DarkContrast = Color3.fromRGB(20, 20, 20),
        TextColor = Color3.fromRGB(255, 255, 255),
        PlaceholderColor = Color3.fromRGB(155, 155, 155),
        VHSOpacity = 0.03
    },
    UISettings = {
        Sounds = true,
        Animations = true,
        VHSEffect = true,
        ScanLines = true,
        BlurEffect = false,
        NotificationDuration = 3,
        CornerRadius = CORNER_RADIUS
    },
    Connections = {},
    GlobalSignals = {
        OnThemeChanged = CreateSignal()
    }
}

-- Create a notification
function T:Notify(title, message, duration)
    duration = duration or self.UISettings.NotificationDuration
    
    -- Play notification sound if sounds are enabled
    if self.UISettings.Sounds then
        SafePlaySound(SOUNDS.Notification)
    end
    
    -- Create notification container if it doesn't exist
    if not self.NotificationContainer then
        self.NotificationContainer = Instance.new("Frame")
        self.NotificationContainer.Name = "TBDNotificationContainer"
        self.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
        self.NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
        self.NotificationContainer.BackgroundTransparency = 1
        self.NotificationContainer.Parent = CoreGui:FindFirstChild("TBDUI") or CoreGui
        
        -- Layout for notifications
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = self.NotificationContainer
    end
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 0)
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.BackgroundColor3 = self.Theme.Background
    notification.BorderSizePixel = 0
    notification.BackgroundTransparency = 0.1
    notification.ClipsDescendants = true
    notification.LayoutOrder = tick() -- Use time for order so newer notifications are at the bottom
    notification.Parent = self.NotificationContainer
    
    -- Notification corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.UISettings.CornerRadius
    corner.Parent = notification
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = self.Theme.Accent
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Name = "Message"
    messageLabel.Size = UDim2.new(1, -20, 0, 0)
    messageLabel.Position = UDim2.new(0, 10, 0, 35)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Text = message
    messageLabel.TextColor3 = self.Theme.TextColor
    messageLabel.TextSize = 16
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextWrapped = true
    messageLabel.AutomaticSize = Enum.AutomaticSize.Y
    messageLabel.Parent = notification
    
    -- VHS Effect for notification
    if self.UISettings.VHSEffect then
        local vhsOverlay = Instance.new("Frame")
        vhsOverlay.Name = "VHSOverlay"
        vhsOverlay.Size = UDim2.new(1, 0, 1, 0)
        vhsOverlay.BackgroundTransparency = 1 - self.Theme.VHSOpacity
        vhsOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        vhsOverlay.BorderSizePixel = 0
        vhsOverlay.ZIndex = 10
        
        -- Apply the vhs texture
        local vhsTexture = Instance.new("ImageLabel")
        vhsTexture.Name = "VHSTexture"
        vhsTexture.Size = UDim2.new(1, 0, 1, 0)
        vhsTexture.BackgroundTransparency = 1
        vhsTexture.Image = "rbxassetid://192736607" -- VHS noise texture
        vhsTexture.ImageTransparency = 0.7
        vhsTexture.ZIndex = 10
        vhsTexture.Parent = vhsOverlay
        
        vhsOverlay.Parent = notification
        
        -- Animate VHS static slightly
        spawn(function()
            while notification and notification.Parent do
                vhsTexture.Position = UDim2.new(0, math.random(-2, 2), 0, math.random(-2, 2))
                wait(0.1)
            end
        end)
    end
    
    -- Progress bar for timer
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = self.Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notification
    
    -- Animate in
    notification.Size = UDim2.new(1, 0, 0, 0)
    local estimatedHeight = 50 + messageLabel.TextBounds.Y
    Tween(notification, {Size = UDim2.new(1, 0, 0, estimatedHeight)})
    
    -- Animate progress bar
    if TweenService and TweenInfo then
        pcall(function()
            local progressTween = TweenService:Create(
                progressBar, 
                TweenInfo.new(duration, Enum.EasingStyle.Linear), 
                {Size = UDim2.new(0, 0, 0, 2)}
            )
            progressTween:Play()
        end)
    end
    
    -- Remove after duration
    spawn(function()
        wait(duration - 0.5)
        if notification and notification.Parent then
            Tween(notification, {Size = UDim2.new(1, 0, 0, 0)})
            wait(0.5)
            pcall(function() notification:Destroy() end)
        end
    end)
    
    return notification
end

-- Set theme for the entire UI
function T:SetTheme(themeOptions)
    for key, value in pairs(themeOptions) do
        if self.Theme[key] ~= nil then
            self.Theme[key] = value
        end
    end
    
    -- Notify all theme listeners
    self.GlobalSignals.OnThemeChanged:Fire(self.Theme)
end

-- Set toggle key for the UI
function T:SetToggleKey(keyCode)
    if not UserInputService or typeof(UserInputService) ~= "table" then return end
    
    -- Remove old connection if it exists
    if self.ToggleKeyConnection then
        pcall(function() self.ToggleKeyConnection:Disconnect() end)
        self.ToggleKeyConnection = nil
    end
    
    -- Create new connection
    self.ToggleKey = keyCode
    pcall(function()
        self.ToggleKeyConnection = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == keyCode then
                self:ToggleUI()
            end
        end)
    end)
end

-- Toggle UI visibility
function T:ToggleUI()
    if not self.MainUI then return end
    
    self.UIVisible = not self.UIVisible
    
    for _, window in pairs(self.Windows) do
        if window.Frame then
            pcall(function() window.Frame.Visible = self.UIVisible end)
        end
    end
end

-- Clean up resources used by the library
function T:Destroy()
    -- Disconnect all connections
    for _, connection in pairs(self.Connections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    
    -- Clear connections table
    self.Connections = {}
    
    -- Destroy all windows
    for _, window in pairs(self.Windows) do
        if window.Frame then
            pcall(function() window.Frame:Destroy() end)
        end
    end
    
    -- Clear windows table
    self.Windows = {}
    
    -- Destroy notification container if it exists
    if self.NotificationContainer then
        pcall(function() self.NotificationContainer:Destroy() end)
        self.NotificationContainer = nil
    end
    
    -- Destroy main UI
    if self.MainUI then
        pcall(function() self.MainUI:Destroy() end)
        self.MainUI = nil
    end
end

-- Main window creation function
function T:CreateWindow(title)
    title = title or "TBD UI Library"
    
    -- Ensure MainUI exists
    if not self.MainUI then
        self.MainUI = Instance.new("ScreenGui")
        self.MainUI.Name = "TBDUI"
        self.MainUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        -- ResetOnSpawn is only available in Roblox
        pcall(function() self.MainUI.ResetOnSpawn = false end)
        
        self.MainUI.Parent = CoreGui
        
        -- Set the first window as visible by default
        self.UIVisible = true
        
        -- Set default toggle key (Right Shift)
        self:SetToggleKey(Enum.KeyCode.RightShift)
    end
    
    -- Create window object
    local window = {
        Tabs = {},
        CurrentTab = nil,
        Drag = {Enabled = false},
        Size = UDim2.new(0, 600, 0, 400),
        Title = title
    }
    
    -- Create window frame
    window.Frame = Instance.new("Frame")
    window.Frame.Name = "Window_" .. title
    window.Frame.Size = window.Size
    window.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
    window.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    window.Frame.BackgroundColor3 = self.Theme.Background
    window.Frame.BorderSizePixel = 0
    window.Frame.ClipsDescendants = true
    window.Frame.Parent = self.MainUI
    
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.UISettings.CornerRadius
    corner.Parent = window.Frame
    
    -- Add window drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageTransparency = 0.5
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.ZIndex = -1
    shadow.Parent = window.Frame
    
    -- Window header
    window.Header = Instance.new("Frame")
    window.Header.Name = "Header"
    window.Header.Size = UDim2.new(1, 0, 0, HEADER_SIZE)
    window.Header.BackgroundColor3 = self.Theme.DarkContrast
    window.Header.BorderSizePixel = 0
    window.Header.Parent = window.Frame
    
    -- Header corner radius (only top corners)
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = self.UISettings.CornerRadius
    headerCorner.Parent = window.Header
    
    -- Make bottom corners square
    local headerSquarify = Instance.new("Frame")
    headerSquarify.Size = UDim2.new(1, 0, 0.5, 0)
    headerSquarify.Position = UDim2.new(0, 0, 0.5, 0)
    headerSquarify.BackgroundColor3 = self.Theme.DarkContrast
    headerSquarify.BorderSizePixel = 0
    headerSquarify.ZIndex = 0
    headerSquarify.Parent = window.Header
    
    -- Window title
    window.Title = Instance.new("TextLabel")
    window.Title.Name = "Title"
    window.Title.Size = UDim2.new(1, -40, 1, 0)
    window.Title.Position = UDim2.new(0, 10, 0, 0)
    window.Title.BackgroundTransparency = 1
    window.Title.Text = title
    window.Title.TextColor3 = self.Theme.TextColor
    window.Title.TextSize = 18
    window.Title.Font = Enum.Font.GothamBold
    window.Title.TextXAlignment = Enum.TextXAlignment.Left
    window.Title.Parent = window.Header
    
    -- Close button
    window.CloseButton = Instance.new("TextButton")
    window.CloseButton.Name = "CloseButton"
    window.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    window.CloseButton.Position = UDim2.new(1, -30, 0.5, 0)
    window.CloseButton.AnchorPoint = Vector2.new(0, 0.5)
    window.CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    window.CloseButton.Text = ""
    window.CloseButton.AutoButtonColor = false
    window.CloseButton.Parent = window.Header
    
    -- Close button corner radius
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = window.CloseButton
    
    -- Close button X
    local closeX = Instance.new("TextLabel")
    closeX.Size = UDim2.new(1, 0, 1, 0)
    closeX.BackgroundTransparency = 1
    closeX.Text = "×"
    closeX.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeX.TextSize = 20
    closeX.Font = Enum.Font.GothamBold
    closeX.Parent = window.CloseButton
    
    -- Dragging functionality
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function OnMouseDown()
        dragging = true
        dragStart = UserInputService:GetMouseLocation()
        startPos = window.Frame.Position
        
        if self.UISettings.Sounds then
            SafePlaySound(SOUNDS.Click)
        end
    end
    
    local function OnMouseUp()
        dragging = false
    end
    
    local function OnMouseMove()
        if dragging and UserInputService and dragStart and startPos then
            pcall(function()
                local mousePos = UserInputService:GetMouseLocation()
                local delta = mousePos - dragStart
                window.Frame.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            end)
        end
    end
    
    -- Connect dragging (using pcall for safety)
    pcall(function()
        window.Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                OnMouseDown()
            end
        end)
        
        window.Header.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                OnMouseUp()
            end
        end)
        
        -- Connect close button
        window.CloseButton.MouseButton1Click:Connect(function()
            if self.UISettings.Sounds then
                SafePlaySound(SOUNDS.Click)
            end
            window.Frame.Visible = false
        end)
        
        -- Connect mouse move for dragging
        table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                OnMouseMove()
            end
        end))
    end)
    
    -- Tabs container (left side)
    window.TabsContainer = Instance.new("Frame")
    window.TabsContainer.Name = "TabsContainer"
    window.TabsContainer.Size = UDim2.new(0, 140, 1, -HEADER_SIZE) 
    window.TabsContainer.Position = UDim2.new(0, 0, 0, HEADER_SIZE)
    window.TabsContainer.BackgroundColor3 = self.Theme.DarkContrast
    window.TabsContainer.BorderSizePixel = 0
    window.TabsContainer.Parent = window.Frame
    
    -- Tabs scrolling frame
    window.TabsScrollFrame = Instance.new("ScrollingFrame")
    window.TabsScrollFrame.Name = "TabsScrollFrame"
    window.TabsScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    window.TabsScrollFrame.BackgroundTransparency = 1
    window.TabsScrollFrame.ScrollBarThickness = 2
    window.TabsScrollFrame.ScrollBarImageColor3 = self.Theme.Accent
    window.TabsScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    window.TabsScrollFrame.BorderSizePixel = 0
    window.TabsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated as tabs are added
    
    -- Try to set AutomaticCanvasSize if it's available (newer Roblox feature)
    pcall(function()
        window.TabsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    end)
    
    window.TabsScrollFrame.Parent = window.TabsContainer
    
    -- Tabs list layout
    local tabsListLayout = Instance.new("UIListLayout")
    tabsListLayout.Padding = UDim.new(0, 6)
    tabsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsListLayout.Parent = window.TabsScrollFrame
    
    -- Tab content frame (right side)
    window.TabContent = Instance.new("Frame")
    window.TabContent.Name = "TabContent"
    window.TabContent.Size = UDim2.new(1, -140, 1, -HEADER_SIZE)
    window.TabContent.Position = UDim2.new(0, 140, 0, HEADER_SIZE)
    window.TabContent.BackgroundColor3 = self.Theme.Background
    window.TabContent.BorderSizePixel = 0
    window.TabContent.ClipsDescendants = true
    window.TabContent.Parent = window.Frame
    
    -- VHS Effect
    if self.UISettings.VHSEffect then
        local vhsOverlay = Instance.new("Frame")
        vhsOverlay.Name = "VHSOverlay"
        vhsOverlay.Size = UDim2.new(1, 0, 1, 0)
        vhsOverlay.BackgroundTransparency = 1 - self.Theme.VHSOpacity
        vhsOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        vhsOverlay.BorderSizePixel = 0
        vhsOverlay.ZIndex = 10
        vhsOverlay.Parent = window.Frame
        
        -- Apply the vhs texture
        local vhsTexture = Instance.new("ImageLabel")
        vhsTexture.Name = "VHSTexture"
        vhsTexture.Size = UDim2.new(1, 0, 1, 0)
        vhsTexture.BackgroundTransparency = 1
        vhsTexture.Image = "rbxassetid://192736607" -- VHS noise texture
        vhsTexture.ImageTransparency = 0.7
        vhsTexture.ZIndex = 10
        vhsTexture.Parent = vhsOverlay
        
        -- Animate VHS static slightly
        spawn(function()
            while window.Frame and window.Frame.Parent do
                vhsTexture.Position = UDim2.new(0, math.random(-2, 2), 0, math.random(-2, 2))
                wait(0.1)
            end
        end)
    end
    
    -- Scan Lines Effect
    if self.UISettings.ScanLines then
        local scanLinesOverlay = Instance.new("Frame")
        scanLinesOverlay.Name = "ScanLinesOverlay"
        scanLinesOverlay.Size = UDim2.new(1, 0, 1, 0)
        scanLinesOverlay.BackgroundTransparency = 1
        scanLinesOverlay.BorderSizePixel = 0
        scanLinesOverlay.ZIndex = 11
        scanLinesOverlay.Parent = window.Frame
        
        -- Apply the scan lines texture
        local scanLinesTexture = Instance.new("ImageLabel")
        scanLinesTexture.Name = "ScanLinesTexture"
        scanLinesTexture.Size = UDim2.new(1, 0, 1, 0)
        scanLinesTexture.BackgroundTransparency = 1
        scanLinesTexture.Image = "rbxassetid://8278639677" -- Scan lines texture
        scanLinesTexture.ImageTransparency = 0.85
        scanLinesTexture.ZIndex = 11
        scanLinesTexture.Parent = scanLinesOverlay
    end
    
    -- Function to create a new tab
    function window:CreateTab(name)
        local tab = {
            Name = name,
            Sections = {},
            Window = self,
            OnShownCallbacks = {}
        }
        
        -- Create tab button
        tab.Button = Instance.new("TextButton")
        tab.Button.Name = "Tab_" .. name
        tab.Button.Size = UDim2.new(1, -20, 0, TAB_HEIGHT)
        tab.Button.BackgroundColor3 = T.Theme.LightContrast
        tab.Button.BorderSizePixel = 0
        tab.Button.Text = name
        tab.Button.TextColor3 = T.Theme.TextColor
        tab.Button.TextSize = 14
        tab.Button.Font = Enum.Font.Gotham
        tab.Button.AutoButtonColor = false
        tab.Button.Parent = self.TabsScrollFrame
        
        -- Tab button corner radius
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = T.UISettings.CornerRadius
        buttonCorner.Parent = tab.Button
        
        -- Create tab content frame
        tab.Container = Instance.new("ScrollingFrame")
        tab.Container.Name = "TabContainer_" .. name
        tab.Container.Size = UDim2.new(1, 0, 1, 0)
        tab.Container.BackgroundTransparency = 1
        tab.Container.BorderSizePixel = 0
        tab.Container.ScrollBarThickness = 2
        tab.Container.ScrollBarImageColor3 = T.Theme.Accent
        tab.Container.ScrollingDirection = Enum.ScrollingDirection.Y
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, 0) -- Will be updated as sections are added
        
        -- Try to set AutomaticCanvasSize if it's available (newer Roblox feature)
        pcall(function()
            tab.Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
        end)
        
        tab.Container.ClipsDescendants = true
        tab.Container.Visible = false
        tab.Container.Parent = self.TabContent
        
        -- Add padding
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 8)
        padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 8)
        padding.PaddingBottom = UDim.new(0, 8)
        padding.Parent = tab.Container
        
        -- Content list layout (vertical arrangement of sections)
        local tabListLayout = Instance.new("UIListLayout")
        tabListLayout.Padding = UDim.new(0, SECTION_SPACING)
        tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabListLayout.Parent = tab.Container
        
        -- Tab button click event (for switching tabs)
        pcall(function()
            tab.Button.MouseButton1Click:Connect(function()
                if T.UISettings.Sounds then
                    SafePlaySound(SOUNDS.Click)
                end
                
                self:SelectTab(tab)
                
                -- Call OnShown callbacks whenever this tab is shown
                for _, callback in ipairs(tab.OnShownCallbacks) do
                    pcall(callback)
                end
            end)
            
            -- Tab button hover effects
            tab.Button.MouseEnter:Connect(function()
                if T.UISettings.Sounds then
                    SafePlaySound(SOUNDS.Hover)
                end
                
                -- Skip hover effect if this is the selected tab
                if self.CurrentTab ~= tab then
                    Tween(tab.Button, {BackgroundColor3 = T.Theme.LightContrast})
                end
            end)
            
            tab.Button.MouseLeave:Connect(function()
                -- Only restore original color if not selected
                if self.CurrentTab ~= tab then
                    Tween(tab.Button, {BackgroundColor3 = T.Theme.DarkContrast})
                end
            end)
        end)
        
        -- Function to add OnTabShown callbacks
        function tab:OnTabShown(callback)
            if type(callback) == "function" then
                table.insert(self.OnShownCallbacks, callback)
            end
        end
        
        -- Function to create a new section within this tab
        function tab:CreateSection(title)
            local section = {
                Name = title,
                Elements = {},
                Tab = self
            }
            
            -- Create section container
            section.Container = Instance.new("Frame")
            section.Container.Name = "Section_" .. title
            section.Container.Size = UDim2.new(1, 0, 0, 0) -- Height will be automatically determined
            section.Container.BackgroundColor3 = T.Theme.LightContrast
            section.Container.BorderSizePixel = 0
            section.Container.ClipsDescendants = true
            
            -- Try to set AutomaticSize if it's available (newer Roblox feature)
            pcall(function()
                section.Container.AutomaticSize = Enum.AutomaticSize.Y
            end)
            
            section.Container.Parent = self.Container
            
            -- Section corner radius
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = T.UISettings.CornerRadius
            sectionCorner.Parent = section.Container
            
            -- Section title
            section.Title = Instance.new("TextLabel")
            section.Title.Name = "Title"
            section.Title.Size = UDim2.new(1, 0, 0, 30)
            section.Title.BackgroundTransparency = 1
            section.Title.Text = title
            section.Title.TextColor3 = T.Theme.TextColor
            section.Title.TextSize = 16
            section.Title.Font = Enum.Font.GothamBold
            section.Title.Parent = section.Container
            
            -- Section content (elements will be added here)
            section.Content = Instance.new("Frame")
            section.Content.Name = "Content"
            section.Content.Size = UDim2.new(1, 0, 0, 0)
            section.Content.Position = UDim2.new(0, 0, 0, 30)
            section.Content.BackgroundTransparency = 1
            
            -- Try to set AutomaticSize if it's available (newer Roblox feature)
            pcall(function()
                section.Content.AutomaticSize = Enum.AutomaticSize.Y
            end)
            
            section.Content.Parent = section.Container
            
            -- Padding for content
            local contentPadding = Instance.new("UIPadding")
            contentPadding.PaddingLeft = UDim.new(0, 8)
            contentPadding.PaddingRight = UDim.new(0, 8)
            contentPadding.PaddingBottom = UDim.new(0, 8)
            contentPadding.Parent = section.Content
            
            -- Layout for elements
            local elementsLayout = Instance.new("UIListLayout")
            elementsLayout.Padding = UDim.new(0, 5)
            elementsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            elementsLayout.Parent = section.Content
            
            -- Add a button element
            function section:AddButton(text, callback)
                callback = callback or function() end
                
                local button = {
                    Name = text,
                    Type = "Button",
                    Section = self
                }
                
                -- Create button instance
                button.Instance = Instance.new("TextButton")
                button.Instance.Name = "Button_" .. text
                button.Instance.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                button.Instance.BackgroundColor3 = T.Theme.DarkContrast
                button.Instance.BorderSizePixel = 0
                button.Instance.Text = text
                button.Instance.TextColor3 = T.Theme.TextColor
                button.Instance.TextSize = 14
                button.Instance.Font = Enum.Font.Gotham
                button.Instance.AutoButtonColor = false
                button.Instance.ClipsDescendants = true -- For ripple effect
                button.Instance.Parent = self.Content
                
                -- Button corner radius
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = T.UISettings.CornerRadius
                buttonCorner.Parent = button.Instance
                
                -- Button hover/click effects
                pcall(function()
                    button.Instance.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(button.Instance, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    button.Instance.MouseLeave:Connect(function()
                        Tween(button.Instance, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                    
                    button.Instance.MouseButton1Down:Connect(function()
                        Tween(button.Instance, {BackgroundColor3 = T.Theme.Accent})
                    end)
                    
                    button.Instance.MouseButton1Up:Connect(function()
                        Tween(button.Instance, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    -- Button click event
                    button.Instance.MouseButton1Click:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Click)
                        end
                        
                        -- Create ripple effect
                        if T.UISettings.Animations then
                            spawn(function()
                                local ripple = Instance.new("Frame")
                                ripple.Name = "Ripple"
                                ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                                ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                ripple.BackgroundTransparency = 0.8
                                ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
                                ripple.Size = UDim2.new(0, 0, 0, 0)
                                
                                local rippleCorner = Instance.new("UICorner")
                                rippleCorner.CornerRadius = UDim.new(0.5, 0)
                                rippleCorner.Parent = ripple
                                
                                ripple.Parent = button.Instance
                                
                                local size = math.max(button.Instance.AbsoluteSize.X, button.Instance.AbsoluteSize.Y) * 1.5
                                Tween(ripple, {Size = UDim2.new(0, size, 0, size), BackgroundTransparency = 1})
                                
                                wait(0.5)
                                if ripple and ripple.Parent then
                                    ripple:Destroy()
                                end
                            end)
                        end
                        
                        -- Call the callback
                        pcall(callback)
                    end)
                end)
                
                -- Add button to section's elements table
                table.insert(self.Elements, button)
                
                return button
            end
            
            -- Add a toggle element
            function section:AddToggle(text, default, callback, flag)
                default = default or false
                callback = callback or function() end
                
                local toggle = {
                    Name = text,
                    Type = "Toggle",
                    Value = default,
                    Section = self
                }
                
                -- Create toggle container
                toggle.Container = Instance.new("Frame")
                toggle.Container.Name = "Toggle_" .. text
                toggle.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                toggle.Container.BackgroundColor3 = T.Theme.DarkContrast
                toggle.Container.BorderSizePixel = 0
                toggle.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = toggle.Container
                
                -- Toggle title
                toggle.Title = Instance.new("TextLabel")
                toggle.Title.Name = "Title"
                toggle.Title.Size = UDim2.new(1, -60, 1, 0)
                toggle.Title.Position = UDim2.new(0, 10, 0, 0)
                toggle.Title.BackgroundTransparency = 1
                toggle.Title.Text = text
                toggle.Title.TextColor3 = T.Theme.TextColor
                toggle.Title.TextSize = 14
                toggle.Title.Font = Enum.Font.Gotham
                toggle.Title.TextXAlignment = Enum.TextXAlignment.Left
                toggle.Title.Parent = toggle.Container
                
                -- Toggle indicator background
                toggle.ToggleBackground = Instance.new("Frame")
                toggle.ToggleBackground.Name = "ToggleBackground"
                toggle.ToggleBackground.Size = UDim2.new(0, 36, 0, 18)
                toggle.ToggleBackground.Position = UDim2.new(1, -46, 0.5, 0)
                toggle.ToggleBackground.AnchorPoint = Vector2.new(0, 0.5)
                toggle.ToggleBackground.BackgroundColor3 = default and T.Theme.Accent or T.Theme.LightContrast
                toggle.ToggleBackground.BorderSizePixel = 0
                toggle.ToggleBackground.Parent = toggle.Container
                
                -- Background corner radius
                local backgroundCorner = Instance.new("UICorner")
                backgroundCorner.CornerRadius = UDim.new(1, 0)
                backgroundCorner.Parent = toggle.ToggleBackground
                
                -- Toggle indicator (the circle that moves)
                toggle.Indicator = Instance.new("Frame")
                toggle.Indicator.Name = "Indicator"
                toggle.Indicator.Size = UDim2.new(0, 14, 0, 14)
                toggle.Indicator.Position = default and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
                toggle.Indicator.AnchorPoint = Vector2.new(0, 0.5)
                toggle.Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                toggle.Indicator.BorderSizePixel = 0
                toggle.Indicator.Parent = toggle.ToggleBackground
                
                -- Indicator corner radius
                local indicatorCorner = Instance.new("UICorner")
                indicatorCorner.CornerRadius = UDim.new(1, 0)
                indicatorCorner.Parent = toggle.Indicator
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    toggle.Flag = flag
                end
                
                -- Function to set toggle value
                function toggle:SetValue(value)
                    self.Value = value
                    
                    -- Update UI
                    Tween(self.ToggleBackground, {BackgroundColor3 = value and T.Theme.Accent or T.Theme.LightContrast})
                    Tween(self.Indicator, {Position = value and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)})
                    
                    -- Update flag value
                    if self.Flag then
                        T.Flags[self.Flag] = value
                    end
                    
                    -- Call callback with new value
                    pcall(callback, value)
                    
                    -- Play sound if enabled
                    if T.UISettings.Sounds then
                        SafePlaySound(SOUNDS.Toggle)
                    end
                end
                
                -- Toggle container click event
                pcall(function()
                    toggle.Container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            toggle:SetValue(not toggle.Value)
                        end
                    end)
                    
                    -- Hover effects
                    toggle.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(toggle.Container, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    toggle.Container.MouseLeave:Connect(function()
                        Tween(toggle.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                end)
                
                -- Add toggle to section's elements table
                table.insert(self.Elements, toggle)
                
                return toggle
            end
            
            -- Add a slider element
            function section:AddSlider(text, min, max, default, callback, flag)
                min = min or 0
                max = max or 100
                default = default or min
                default = math.clamp(default, min, max)
                callback = callback or function() end
                
                local slider = {
                    Name = text,
                    Type = "Slider",
                    Value = default,
                    Min = min,
                    Max = max,
                    Section = self
                }
                
                -- Create slider container
                slider.Container = Instance.new("Frame")
                slider.Container.Name = "Slider_" .. text
                slider.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT * 1.5)
                slider.Container.BackgroundColor3 = T.Theme.DarkContrast
                slider.Container.BorderSizePixel = 0
                slider.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = slider.Container
                
                -- Slider title
                slider.Title = Instance.new("TextLabel")
                slider.Title.Name = "Title"
                slider.Title.Size = UDim2.new(1, -140, 0, 20)
                slider.Title.Position = UDim2.new(0, 10, 0, 5)
                slider.Title.BackgroundTransparency = 1
                slider.Title.Text = text
                slider.Title.TextColor3 = T.Theme.TextColor
                slider.Title.TextSize = 14
                slider.Title.Font = Enum.Font.Gotham
                slider.Title.TextXAlignment = Enum.TextXAlignment.Left
                slider.Title.Parent = slider.Container
                
                -- Value display
                slider.ValueDisplay = Instance.new("TextBox")
                slider.ValueDisplay.Name = "ValueDisplay"
                slider.ValueDisplay.Size = UDim2.new(0, 50, 0, 20)
                slider.ValueDisplay.Position = UDim2.new(1, -60, 0, 5)
                slider.ValueDisplay.BackgroundColor3 = T.Theme.LightContrast
                slider.ValueDisplay.BorderSizePixel = 0
                slider.ValueDisplay.Text = tostring(default)
                slider.ValueDisplay.TextColor3 = T.Theme.TextColor
                slider.ValueDisplay.TextSize = 12
                slider.ValueDisplay.Font = Enum.Font.Gotham
                slider.ValueDisplay.Parent = slider.Container
                
                -- Value display corner radius
                local valueCorner = Instance.new("UICorner")
                valueCorner.CornerRadius = UDim.new(0, 4)
                valueCorner.Parent = slider.ValueDisplay
                
                -- Slider bar background
                slider.SliderBackground = Instance.new("Frame")
                slider.SliderBackground.Name = "SliderBackground"
                slider.SliderBackground.Size = UDim2.new(1, -20, 0, 8)
                slider.SliderBackground.Position = UDim2.new(0, 10, 0, 30)
                slider.SliderBackground.BackgroundColor3 = T.Theme.LightContrast
                slider.SliderBackground.BorderSizePixel = 0
                slider.SliderBackground.Parent = slider.Container
                
                -- Background corner radius
                local backgroundCorner = Instance.new("UICorner")
                backgroundCorner.CornerRadius = UDim.new(0, 4)
                backgroundCorner.Parent = slider.SliderBackground
                
                -- Slider fill (shows current value)
                slider.Fill = Instance.new("Frame")
                slider.Fill.Name = "Fill"
                slider.Fill.BackgroundColor3 = T.Theme.Accent
                slider.Fill.BorderSizePixel = 0
                slider.Fill.Parent = slider.SliderBackground
                
                -- Fill corner radius
                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, 4)
                fillCorner.Parent = slider.Fill
                
                -- Calculate initial fill size from default value
                local initialFillSize = ((default - min) / (max - min))
                slider.Fill.Size = UDim2.new(initialFillSize, 0, 1, 0)
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    slider.Flag = flag
                end
                
                -- Function to update slider visually and trigger callback
                function slider:SetValue(value, updateTextbox)
                    -- Clamp value to min/max
                    value = math.clamp(value, self.Min, self.Max)
                    self.Value = value
                    
                    -- Calculate fill size (percentage)
                    local fillSize = ((value - self.Min) / (self.Max - self.Min))
                    self.Fill.Size = UDim2.new(fillSize, 0, 1, 0)
                    
                    -- Update textbox if needed
                    if updateTextbox then
                        self.ValueDisplay.Text = tostring(math.round(value))
                    end
                    
                    -- Update flag if set
                    if self.Flag then
                        T.Flags[self.Flag] = value
                    end
                    
                    -- Call callback with new value
                    pcall(callback, value)
                end
                
                -- Handle slider dragging
                local isDragging = false
                
                pcall(function()
                    slider.SliderBackground.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if T.UISettings.Sounds then
                                SafePlaySound(SOUNDS.Click)
                            end
                            
                            isDragging = true
                            
                            -- Update based on initial click position
                            local sliderPosition = slider.SliderBackground.AbsolutePosition.X
                            local sliderWidth = slider.SliderBackground.AbsoluteSize.X
                            local mousePosition = input.Position.X
                            
                            local relativePosition = (mousePosition - sliderPosition) / sliderWidth
                            local value = min + ((max - min) * relativePosition)
                            
                            slider:SetValue(value, true)
                        end
                    end)
                    
                    slider.SliderBackground.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            isDragging = false
                        end
                    end)
                    
                    -- Mouse movement handler for dragging
                    table.insert(T.Connections, UserInputService.InputChanged:Connect(function(input)
                        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local sliderPosition = slider.SliderBackground.AbsolutePosition.X
                            local sliderWidth = slider.SliderBackground.AbsoluteSize.X
                            local mousePosition = input.Position.X
                            
                            local relativePosition = (mousePosition - sliderPosition) / sliderWidth
                            local value = min + ((max - min) * relativePosition)
                            
                            slider:SetValue(value, true)
                        end
                    end))
                    
                    -- Handle value input via TextBox
                    slider.ValueDisplay.FocusLost:Connect(function(enterPressed)
                        if enterPressed then
                            local inputValue = tonumber(slider.ValueDisplay.Text)
                            if inputValue then
                                slider:SetValue(inputValue, true)
                            else
                                -- Reset to current value if input is invalid
                                slider.ValueDisplay.Text = tostring(math.round(slider.Value))
                            end
                        else
                            -- Reset text to current value if focus is lost without pressing enter
                            slider.ValueDisplay.Text = tostring(math.round(slider.Value))
                        end
                    end)
                    
                    -- Hover effects
                    slider.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(slider.Container, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    slider.Container.MouseLeave:Connect(function()
                        Tween(slider.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                end)
                
                -- Add slider to section's elements table
                table.insert(self.Elements, slider)
                
                return slider
            end
            
            -- Add a dropdown element
            function section:AddDropdown(text, options, default, callback, flag)
                options = options or {}
                default = default or options[1] or ""
                callback = callback or function() end
                
                local dropdown = {
                    Name = text,
                    Type = "Dropdown",
                    Value = default,
                    Options = options,
                    Section = self,
                    Open = false
                }
                
                -- Create dropdown container
                dropdown.Container = Instance.new("Frame")
                dropdown.Container.Name = "Dropdown_" .. text
                dropdown.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                dropdown.Container.BackgroundColor3 = T.Theme.DarkContrast
                dropdown.Container.BorderSizePixel = 0
                dropdown.Container.ClipsDescendants = true
                dropdown.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = dropdown.Container
                
                -- Dropdown title
                dropdown.Title = Instance.new("TextLabel")
                dropdown.Title.Name = "Title"
                dropdown.Title.Size = UDim2.new(1, -20, 0, 20)
                dropdown.Title.Position = UDim2.new(0, 10, 0, 3)
                dropdown.Title.BackgroundTransparency = 1
                dropdown.Title.Text = text
                dropdown.Title.TextColor3 = T.Theme.TextColor
                dropdown.Title.TextSize = 14
                dropdown.Title.Font = Enum.Font.Gotham
                dropdown.Title.TextXAlignment = Enum.TextXAlignment.Left
                dropdown.Title.Parent = dropdown.Container
                
                -- Selected value display
                dropdown.Selected = Instance.new("TextLabel")
                dropdown.Selected.Name = "Selected"
                dropdown.Selected.Size = UDim2.new(1, -20, 0, 20)
                dropdown.Selected.Position = UDim2.new(0, 10, 0, 16)
                dropdown.Selected.BackgroundTransparency = 1
                dropdown.Selected.Text = default
                dropdown.Selected.TextColor3 = T.Theme.Accent
                dropdown.Selected.TextSize = 12
                dropdown.Selected.Font = Enum.Font.Gotham
                dropdown.Selected.TextXAlignment = Enum.TextXAlignment.Left
                dropdown.Selected.Parent = dropdown.Container
                
                -- Dropdown arrow
                dropdown.Arrow = Instance.new("TextLabel")
                dropdown.Arrow.Name = "Arrow"
                dropdown.Arrow.Size = UDim2.new(0, 20, 0, 20)
                dropdown.Arrow.Position = UDim2.new(1, -25, 0, 8)
                dropdown.Arrow.BackgroundTransparency = 1
                dropdown.Arrow.Text = "▼"
                dropdown.Arrow.TextColor3 = T.Theme.TextColor
                dropdown.Arrow.TextSize = 12
                dropdown.Arrow.Font = Enum.Font.Gotham
                dropdown.Arrow.Parent = dropdown.Container
                
                -- Options container (will be shown when dropdown is open)
                dropdown.OptionsContainer = Instance.new("Frame")
                dropdown.OptionsContainer.Name = "OptionsContainer"
                dropdown.OptionsContainer.Size = UDim2.new(1, -20, 0, 0) -- Height will be set dynamically
                dropdown.OptionsContainer.Position = UDim2.new(0, 10, 0, ELEMENT_HEIGHT)
                dropdown.OptionsContainer.BackgroundColor3 = T.Theme.LightContrast
                dropdown.OptionsContainer.BorderSizePixel = 0
                dropdown.OptionsContainer.Visible = false
                dropdown.OptionsContainer.Parent = dropdown.Container
                
                -- Options container corner radius
                local optionsCorner = Instance.new("UICorner")
                optionsCorner.CornerRadius = UDim.new(0, 4)
                optionsCorner.Parent = dropdown.OptionsContainer
                
                -- Options list layout
                local optionsLayout = Instance.new("UIListLayout")
                optionsLayout.Padding = UDim.new(0, 2)
                optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Parent = dropdown.OptionsContainer
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    dropdown.Flag = flag
                end
                
                -- Function to set dropdown value
                function dropdown:SetValue(value)
                    if table.find(self.Options, value) then
                        self.Value = value
                        self.Selected.Text = value
                        
                        -- Update flag if set
                        if self.Flag then
                            T.Flags[self.Flag] = value
                        end
                        
                        -- Call callback with new value
                        pcall(callback, value)
                    end
                end
                
                -- Function to update options
                function dropdown:UpdateOptions(newOptions, newValue)
                    self.Options = newOptions
                    
                    -- Clear current option buttons
                    for _, child in ipairs(self.OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Rebuild option buttons
                    self:Refresh()
                    
                    -- Set new value if provided
                    if newValue and table.find(newOptions, newValue) then
                        self:SetValue(newValue)
                    elseif #newOptions > 0 then
                        self:SetValue(newOptions[1])
                    else
                        self.Value = ""
                        self.Selected.Text = ""
                    end
                end
                
                -- Function to refresh dropdown options display
                function dropdown:Refresh()
                    -- Clear existing options
                    for _, child in pairs(self.OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add option buttons
                    for i, option in ipairs(self.Options) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Name = "Option_" .. option
                        optionButton.Size = UDim2.new(1, -4, 0, 24)
                        optionButton.BackgroundColor3 = self.Value == option and T.Theme.Accent or T.Theme.DarkContrast
                        optionButton.BorderSizePixel = 0
                        optionButton.Text = option
                        optionButton.TextColor3 = T.Theme.TextColor
                        optionButton.TextSize = 12
                        optionButton.Font = Enum.Font.Gotham
                        optionButton.LayoutOrder = i
                        optionButton.Parent = self.OptionsContainer
                        
                        -- Option button corner radius
                        local optionCorner = Instance.new("UICorner")
                        optionCorner.CornerRadius = UDim.new(0, 4)
                        optionCorner.Parent = optionButton
                        
                        -- Option button click event
                        pcall(function()
                            optionButton.MouseButton1Click:Connect(function()
                                if T.UISettings.Sounds then
                                    SafePlaySound(SOUNDS.Click)
                                end
                                
                                -- Set value to this option
                                self:SetValue(option)
                                
                                -- Close dropdown
                                self:Toggle(false)
                            end)
                            
                            -- Hover effects
                            optionButton.MouseEnter:Connect(function()
                                if T.UISettings.Sounds then
                                    SafePlaySound(SOUNDS.Hover)
                                end
                                
                                if self.Value ~= option then
                                    Tween(optionButton, {BackgroundColor3 = T.Theme.LightContrast})
                                end
                            end)
                            
                            optionButton.MouseLeave:Connect(function()
                                if self.Value ~= option then
                                    Tween(optionButton, {BackgroundColor3 = T.Theme.DarkContrast})
                                end
                            end)
                        end)
                    end
                    
                    -- Update options container height based on number of options
                    local optionsHeight = #self.Options * 26 -- 24 for button height + 2 for padding
                    self.OptionsContainer.Size = UDim2.new(1, -20, 0, optionsHeight)
                    
                    -- Calculate expanded container size
                    self.ExpandedSize = UDim2.new(1, 0, 0, ELEMENT_HEIGHT + optionsHeight + 10)
                end
                
                -- Function to toggle dropdown open/closed
                function dropdown:Toggle(open)
                    if open == nil then
                        open = not self.Open
                    end
                    
                    self.Open = open
                    
                    if open then
                        -- Show options
                        self.OptionsContainer.Visible = true
                        self.Arrow.Text = "▲"
                        self.Arrow.Rotation = 180
                        
                        -- Expand container to fit options
                        Tween(self.Container, {Size = self.ExpandedSize})
                    else
                        -- Hide options
                        self.Arrow.Text = "▼"
                        self.Arrow.Rotation = 0
                        
                        -- Shrink container back to normal size
                        Tween(self.Container, {Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)})
                        
                        -- Set options invisible after animation completes
                        spawn(function()
                            wait(0.2)
                            if not self.Open then
                                self.OptionsContainer.Visible = false
                            end
                        end)
                    end
                end
                
                -- Create initial options
                dropdown:Refresh()
                
                -- Container click event to toggle dropdown
                pcall(function()
                    dropdown.Container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and 
                           input.Position.Y <= dropdown.Container.AbsolutePosition.Y + ELEMENT_HEIGHT then
                            if T.UISettings.Sounds then
                                SafePlaySound(SOUNDS.Click)
                            end
                            
                            dropdown:Toggle()
                        end
                    end)
                    
                    -- Close dropdown when clicking elsewhere
                    table.insert(T.Connections, UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdown.Open then
                            local mousePos = UserInputService:GetMouseLocation()
                            local containerPos = dropdown.Container.AbsolutePosition
                            local containerSize = dropdown.Container.AbsoluteSize
                            
                            -- Check if click is outside container
                            if mousePos.X < containerPos.X or 
                               mousePos.X > containerPos.X + containerSize.X or
                               mousePos.Y < containerPos.Y or
                               mousePos.Y > containerPos.Y + containerSize.Y then
                                dropdown:Toggle(false)
                            end
                        end
                    end))
                    
                    -- Hover effects
                    dropdown.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        if not dropdown.Open then
                            Tween(dropdown.Container, {BackgroundColor3 = T.Theme.LightContrast})
                        end
                    end)
                    
                    dropdown.Container.MouseLeave:Connect(function()
                        if not dropdown.Open then
                            Tween(dropdown.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                        end
                    end)
                end)
                
                -- Add dropdown to section's elements table
                table.insert(self.Elements, dropdown)
                
                return dropdown
            end
            
            -- Add a textbox element
            function section:AddTextbox(text, default, placeholder, callback, flag)
                default = default or ""
                placeholder = placeholder or "Enter text..."
                callback = callback or function() end
                
                local textbox = {
                    Name = text,
                    Type = "Textbox",
                    Value = default,
                    Section = self
                }
                
                -- Create textbox container
                textbox.Container = Instance.new("Frame")
                textbox.Container.Name = "Textbox_" .. text
                textbox.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                textbox.Container.BackgroundColor3 = T.Theme.DarkContrast
                textbox.Container.BorderSizePixel = 0
                textbox.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = textbox.Container
                
                -- Textbox title
                textbox.Title = Instance.new("TextLabel")
                textbox.Title.Name = "Title"
                textbox.Title.Size = UDim2.new(1, -20, 0, 20)
                textbox.Title.Position = UDim2.new(0, 10, 0, 3)
                textbox.Title.BackgroundTransparency = 1
                textbox.Title.Text = text
                textbox.Title.TextColor3 = T.Theme.TextColor
                textbox.Title.TextSize = 14
                textbox.Title.Font = Enum.Font.Gotham
                textbox.Title.TextXAlignment = Enum.TextXAlignment.Left
                textbox.Title.Parent = textbox.Container
                
                -- Input field
                textbox.Input = Instance.new("TextBox")
                textbox.Input.Name = "Input"
                textbox.Input.Size = UDim2.new(1, -20, 0, 20)
                textbox.Input.Position = UDim2.new(0, 10, 0, 20)
                textbox.Input.BackgroundColor3 = T.Theme.LightContrast
                textbox.Input.BorderSizePixel = 0
                textbox.Input.Text = default
                textbox.Input.PlaceholderText = placeholder
                textbox.Input.TextColor3 = T.Theme.TextColor
                textbox.Input.PlaceholderColor3 = T.Theme.PlaceholderColor
                textbox.Input.TextSize = 12
                textbox.Input.Font = Enum.Font.Gotham
                textbox.Input.TextXAlignment = Enum.TextXAlignment.Left
                textbox.Input.ClearTextOnFocus = false
                textbox.Input.Parent = textbox.Container
                
                -- Input corner radius
                local inputCorner = Instance.new("UICorner")
                inputCorner.CornerRadius = UDim.new(0, 4)
                inputCorner.Parent = textbox.Input
                
                -- Add padding to input field
                local inputPadding = Instance.new("UIPadding")
                inputPadding.PaddingLeft = UDim.new(0, 5)
                inputPadding.Parent = textbox.Input
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    textbox.Flag = flag
                end
                
                -- Function to set textbox value
                function textbox:SetValue(value)
                    value = tostring(value)
                    self.Value = value
                    self.Input.Text = value
                    
                    -- Update flag if set
                    if self.Flag then
                        T.Flags[self.Flag] = value
                    end
                    
                    -- Call callback with new value
                    pcall(callback, value)
                end
                
                -- Handle focus lost (text entered)
                pcall(function()
                    textbox.Input.FocusLost:Connect(function(enterPressed)
                        local newValue = textbox.Input.Text
                        
                        -- Always update value on focus lost (even without Enter)
                        textbox:SetValue(newValue)
                        
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Click)
                        end
                    end)
                    
                    -- Hover effects
                    textbox.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(textbox.Container, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    textbox.Container.MouseLeave:Connect(function()
                        Tween(textbox.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                end)
                
                -- Add textbox to section's elements table
                table.insert(self.Elements, textbox)
                
                return textbox
            end
            
            -- Add a label element
            function section:AddLabel(text)
                local label = {
                    Name = text,
                    Type = "Label",
                    Section = self
                }
                
                -- Create label instance
                label.Instance = Instance.new("TextLabel")
                label.Instance.Name = "Label_" .. text
                label.Instance.Size = UDim2.new(1, 0, 0, 24)
                label.Instance.BackgroundTransparency = 1
                label.Instance.Text = text
                label.Instance.TextColor3 = T.Theme.TextColor
                label.Instance.TextSize = 14
                label.Instance.Font = Enum.Font.Gotham
                label.Instance.Parent = self.Content
                
                -- Function to update label text
                function label:SetText(newText)
                    self.Name = newText
                    self.Instance.Text = newText
                end
                
                -- Add label to section's elements table
                table.insert(self.Elements, label)
                
                return label
            end
            
            -- Add a keybind element
            function section:AddKeybind(text, default, callback, flag)
                default = default or Enum.KeyCode.Unknown
                callback = callback or function() end
                
                local keybind = {
                    Name = text,
                    Type = "Keybind",
                    Value = default,
                    Listening = false,
                    Section = self
                }
                
                -- Create keybind container
                keybind.Container = Instance.new("Frame")
                keybind.Container.Name = "Keybind_" .. text
                keybind.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                keybind.Container.BackgroundColor3 = T.Theme.DarkContrast
                keybind.Container.BorderSizePixel = 0
                keybind.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = keybind.Container
                
                -- Keybind title
                keybind.Title = Instance.new("TextLabel")
                keybind.Title.Name = "Title"
                keybind.Title.Size = UDim2.new(1, -100, 1, 0)
                keybind.Title.Position = UDim2.new(0, 10, 0, 0)
                keybind.Title.BackgroundTransparency = 1
                keybind.Title.Text = text
                keybind.Title.TextColor3 = T.Theme.TextColor
                keybind.Title.TextSize = 14
                keybind.Title.Font = Enum.Font.Gotham
                keybind.Title.TextXAlignment = Enum.TextXAlignment.Left
                keybind.Title.Parent = keybind.Container
                
                -- Keybind button
                keybind.Button = Instance.new("TextButton")
                keybind.Button.Name = "Button"
                keybind.Button.Size = UDim2.new(0, 80, 0, 24)
                keybind.Button.Position = UDim2.new(1, -90, 0.5, 0)
                keybind.Button.AnchorPoint = Vector2.new(0, 0.5)
                keybind.Button.BackgroundColor3 = T.Theme.LightContrast
                keybind.Button.BorderSizePixel = 0
                keybind.Button.Text = default and (type(default) == "string" and default or default.Name) or "None"
                keybind.Button.TextColor3 = T.Theme.TextColor
                keybind.Button.TextSize = 12
                keybind.Button.Font = Enum.Font.Gotham
                keybind.Button.Parent = keybind.Container
                
                -- Button corner radius
                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 4)
                buttonCorner.Parent = keybind.Button
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    keybind.Flag = flag
                end
                
                -- Function to set keybind value
                function keybind:SetValue(value)
                    self.Value = value
                    self.Button.Text = value and (type(value) == "string" and value or value.Name) or "None"
                    
                    -- Update flag if set
                    if self.Flag then
                        T.Flags[self.Flag] = value
                    end
                    
                    -- Call callback with new value
                    pcall(callback, value)
                end
                
                -- Function to start listening for key press
                function keybind:StartListening()
                    self.Listening = true
                    self.Button.Text = "..."
                    
                    -- Change button color to accent during listening
                    Tween(self.Button, {BackgroundColor3 = T.Theme.Accent})
                end
                
                -- Function to stop listening without setting a new key
                function keybind:StopListening()
                    self.Listening = false
                    self.Button.Text = self.Value and (type(self.Value) == "string" and self.Value or self.Value.Name) or "None"
                    
                    -- Restore button color
                    Tween(self.Button, {BackgroundColor3 = T.Theme.LightContrast})
                end
                
                -- Button click event to start listening
                pcall(function()
                    keybind.Button.MouseButton1Click:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Click)
                        end
                        
                        -- Toggle listening state
                        if keybind.Listening then
                            keybind:StopListening()
                        else
                            keybind:StartListening()
                        end
                    end)
                    
                    -- Listen for key press when in listening mode
                    table.insert(T.Connections, UserInputService.InputBegan:Connect(function(input)
                        if keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            -- Set new keybind
                            keybind:SetValue(input.KeyCode)
                            
                            -- Stop listening
                            keybind:StopListening()
                            
                            if T.UISettings.Sounds then
                                SafePlaySound(SOUNDS.Click)
                            end
                        end
                    end))
                    
                    -- Hover effects
                    keybind.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(keybind.Container, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    keybind.Container.MouseLeave:Connect(function()
                        Tween(keybind.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                    
                    keybind.Button.MouseEnter:Connect(function()
                        if not keybind.Listening then
                            Tween(keybind.Button, {BackgroundColor3 = T.Theme.LightContrast})
                        end
                    end)
                    
                    keybind.Button.MouseLeave:Connect(function()
                        if not keybind.Listening then
                            Tween(keybind.Button, {BackgroundColor3 = T.Theme.DarkContrast})
                        end
                    end)
                end)
                
                -- Add keybind to section's elements table
                table.insert(self.Elements, keybind)
                
                return keybind
            end
            
            -- Add a color picker element
            function section:AddColorPicker(text, default, callback, flag)
                default = default or Color3.fromRGB(255, 255, 255)
                callback = callback or function() end
                
                local colorPicker = {
                    Name = text,
                    Type = "ColorPicker",
                    Value = default,
                    Section = self,
                    Open = false
                }
                
                -- Create colorPicker container
                colorPicker.Container = Instance.new("Frame")
                colorPicker.Container.Name = "ColorPicker_" .. text
                colorPicker.Container.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
                colorPicker.Container.BackgroundColor3 = T.Theme.DarkContrast
                colorPicker.Container.BorderSizePixel = 0
                colorPicker.Container.ClipsDescendants = true
                colorPicker.Container.Parent = self.Content
                
                -- Container corner radius
                local containerCorner = Instance.new("UICorner")
                containerCorner.CornerRadius = T.UISettings.CornerRadius
                containerCorner.Parent = colorPicker.Container
                
                -- ColorPicker title
                colorPicker.Title = Instance.new("TextLabel")
                colorPicker.Title.Name = "Title"
                colorPicker.Title.Size = UDim2.new(1, -60, 1, 0)
                colorPicker.Title.Position = UDim2.new(0, 10, 0, 0)
                colorPicker.Title.BackgroundTransparency = 1
                colorPicker.Title.Text = text
                colorPicker.Title.TextColor3 = T.Theme.TextColor
                colorPicker.Title.TextSize = 14
                colorPicker.Title.Font = Enum.Font.Gotham
                colorPicker.Title.TextXAlignment = Enum.TextXAlignment.Left
                colorPicker.Title.Parent = colorPicker.Container
                
                -- Color display
                colorPicker.Display = Instance.new("Frame")
                colorPicker.Display.Name = "Display"
                colorPicker.Display.Size = UDim2.new(0, 30, 0, 16)
                colorPicker.Display.Position = UDim2.new(1, -40, 0.5, 0)
                colorPicker.Display.AnchorPoint = Vector2.new(0, 0.5)
                colorPicker.Display.BackgroundColor3 = default
                colorPicker.Display.BorderSizePixel = 0
                colorPicker.Display.Parent = colorPicker.Container
                
                -- Display corner radius
                local displayCorner = Instance.new("UICorner")
                displayCorner.CornerRadius = UDim.new(0, 4)
                displayCorner.Parent = colorPicker.Display
                
                -- Store the flag if provided
                if flag then
                    T.Flags[flag] = default
                    colorPicker.Flag = flag
                end
                
                -- Function to set color
                function colorPicker:SetValue(color)
                    self.Value = color
                    self.Display.BackgroundColor3 = color
                    
                    -- Update flag if set
                    if self.Flag then
                        T.Flags[self.Flag] = color
                    end
                    
                    -- Call callback with new value
                    pcall(callback, color)
                    
                    -- Update RGB values if picker is open
                    if self.Open and self.ColorPickerUI then
                        pcall(function()
                            self.RInput.Text = tostring(math.round(color.R * 255))
                            self.GInput.Text = tostring(math.round(color.G * 255))
                            self.BInput.Text = tostring(math.round(color.B * 255))
                        end)
                    end
                end
                
                -- Function to create color picker UI
                function colorPicker:CreatePickerUI()
                    -- Color picker UI
                    self.ColorPickerUI = Instance.new("Frame")
                    self.ColorPickerUI.Name = "ColorPickerUI"
                    self.ColorPickerUI.Size = UDim2.new(1, -20, 0, 120)
                    self.ColorPickerUI.Position = UDim2.new(0, 10, 0, ELEMENT_HEIGHT + 5)
                    self.ColorPickerUI.BackgroundColor3 = T.Theme.LightContrast
                    self.ColorPickerUI.BorderSizePixel = 0
                    self.ColorPickerUI.Visible = false
                    self.ColorPickerUI.Parent = self.Container
                    
                    -- ColorPickerUI corner radius
                    local pickerCorner = Instance.new("UICorner")
                    pickerCorner.CornerRadius = T.UISettings.CornerRadius
                    pickerCorner.Parent = self.ColorPickerUI
                    
                    -- Create RGB inputs
                    self.RInput = Instance.new("TextBox")
                    self.RInput.Name = "RInput"
                    self.RInput.Size = UDim2.new(0, 50, 0, 20)
                    self.RInput.Position = UDim2.new(0, 10, 0, 10)
                    self.RInput.BackgroundColor3 = T.Theme.DarkContrast
                    self.RInput.BorderSizePixel = 0
                    self.RInput.Text = tostring(math.round(self.Value.R * 255))
                    self.RInput.TextColor3 = T.Theme.TextColor
                    self.RInput.PlaceholderText = "R"
                    self.RInput.PlaceholderColor3 = T.Theme.PlaceholderColor
                    self.RInput.TextSize = 12
                    self.RInput.Font = Enum.Font.Gotham
                    self.RInput.Parent = self.ColorPickerUI
                    
                    -- RInput corner radius
                    local rCorner = Instance.new("UICorner")
                    rCorner.CornerRadius = UDim.new(0, 4)
                    rCorner.Parent = self.RInput
                    
                    self.GInput = Instance.new("TextBox")
                    self.GInput.Name = "GInput"
                    self.GInput.Size = UDim2.new(0, 50, 0, 20)
                    self.GInput.Position = UDim2.new(0, 70, 0, 10)
                    self.GInput.BackgroundColor3 = T.Theme.DarkContrast
                    self.GInput.BorderSizePixel = 0
                    self.GInput.Text = tostring(math.round(self.Value.G * 255))
                    self.GInput.TextColor3 = T.Theme.TextColor
                    self.GInput.PlaceholderText = "G"
                    self.GInput.PlaceholderColor3 = T.Theme.PlaceholderColor
                    self.GInput.TextSize = 12
                    self.GInput.Font = Enum.Font.Gotham
                    self.GInput.Parent = self.ColorPickerUI
                    
                    -- GInput corner radius
                    local gCorner = Instance.new("UICorner")
                    gCorner.CornerRadius = UDim.new(0, 4)
                    gCorner.Parent = self.GInput
                    
                    self.BInput = Instance.new("TextBox")
                    self.BInput.Name = "BInput"
                    self.BInput.Size = UDim2.new(0, 50, 0, 20)
                    self.BInput.Position = UDim2.new(0, 130, 0, 10)
                    self.BInput.BackgroundColor3 = T.Theme.DarkContrast
                    self.BInput.BorderSizePixel = 0
                    self.BInput.Text = tostring(math.round(self.Value.B * 255))
                    self.BInput.TextColor3 = T.Theme.TextColor
                    self.BInput.PlaceholderText = "B"
                    self.BInput.PlaceholderColor3 = T.Theme.PlaceholderColor
                    self.BInput.TextSize = 12
                    self.BInput.Font = Enum.Font.Gotham
                    self.BInput.Parent = self.ColorPickerUI
                    
                    -- BInput corner radius
                    local bCorner = Instance.new("UICorner")
                    bCorner.CornerRadius = UDim.new(0, 4)
                    bCorner.Parent = self.BInput
                    
                    -- Color preview
                    self.ColorPreview = Instance.new("Frame")
                    self.ColorPreview.Name = "ColorPreview"
                    self.ColorPreview.Size = UDim2.new(1, -20, 0, 40)
                    self.ColorPreview.Position = UDim2.new(0, 10, 0, 40)
                    self.ColorPreview.BackgroundColor3 = self.Value
                    self.ColorPreview.BorderSizePixel = 0
                    self.ColorPreview.Parent = self.ColorPickerUI
                    
                    -- ColorPreview corner radius
                    local previewCorner = Instance.new("UICorner")
                    previewCorner.CornerRadius = UDim.new(0, 4)
                    previewCorner.Parent = self.ColorPreview
                    
                    -- Apply button
                    self.ApplyButton = Instance.new("TextButton")
                    self.ApplyButton.Name = "ApplyButton"
                    self.ApplyButton.Size = UDim2.new(1, -20, 0, 20)
                    self.ApplyButton.Position = UDim2.new(0, 10, 0, 90)
                    self.ApplyButton.BackgroundColor3 = T.Theme.Accent
                    self.ApplyButton.BorderSizePixel = 0
                    self.ApplyButton.Text = "Apply"
                    self.ApplyButton.TextColor3 = T.Theme.TextColor
                    self.ApplyButton.TextSize = 14
                    self.ApplyButton.Font = Enum.Font.Gotham
                    self.ApplyButton.Parent = self.ColorPickerUI
                    
                    -- ApplyButton corner radius
                    local applyCorner = Instance.new("UICorner")
                    applyCorner.CornerRadius = UDim.new(0, 4)
                    applyCorner.Parent = self.ApplyButton
                    
                    -- Handle RGB input changes
                    local function updateFromRGB()
                        pcall(function()
                            local r = tonumber(self.RInput.Text) or 0
                            local g = tonumber(self.GInput.Text) or 0
                            local b = tonumber(self.BInput.Text) or 0
                            
                            r = math.clamp(r, 0, 255) / 255
                            g = math.clamp(g, 0, 255) / 255
                            b = math.clamp(b, 0, 255) / 255
                            
                            local newColor = Color3.new(r, g, b)
                            self.ColorPreview.BackgroundColor3 = newColor
                        end)
                    end
                    
                    -- Apply button click
                    pcall(function()
                        self.ApplyButton.MouseButton1Click:Connect(function()
                            if T.UISettings.Sounds then
                                SafePlaySound(SOUNDS.Click)
                            end
                            
                            local newColor = self.ColorPreview.BackgroundColor3
                            self:SetValue(newColor)
                            self:Toggle(false)
                        end)
                        
                        self.RInput.FocusLost:Connect(updateFromRGB)
                        self.GInput.FocusLost:Connect(updateFromRGB)
                        self.BInput.FocusLost:Connect(updateFromRGB)
                    end)
                end
                
                -- Function to toggle color picker open/closed
                function colorPicker:Toggle(open)
                    if open == nil then
                        open = not self.Open
                    end
                    
                    self.Open = open
                    
                    if open then
                        -- Create picker UI if it doesn't exist
                        if not self.ColorPickerUI then
                            self:CreatePickerUI()
                        end
                        
                        -- Show color picker
                        self.ColorPickerUI.Visible = true
                        
                        -- Expand container to fit color picker
                        Tween(self.Container, {Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT + 130)})
                    else
                        -- Hide color picker
                        if self.ColorPickerUI then
                            self.ColorPickerUI.Visible = false
                        end
                        
                        -- Shrink container back to normal size
                        Tween(self.Container, {Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)})
                    end
                end
                
                -- Container click event to toggle color picker
                pcall(function()
                    colorPicker.Container.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if T.UISettings.Sounds then
                                SafePlaySound(SOUNDS.Click)
                            end
                            
                            colorPicker:Toggle()
                        end
                    end)
                    
                    -- Hover effects
                    colorPicker.Container.MouseEnter:Connect(function()
                        if T.UISettings.Sounds then
                            SafePlaySound(SOUNDS.Hover)
                        end
                        
                        Tween(colorPicker.Container, {BackgroundColor3 = T.Theme.LightContrast})
                    end)
                    
                    colorPicker.Container.MouseLeave:Connect(function()
                        Tween(colorPicker.Container, {BackgroundColor3 = T.Theme.DarkContrast})
                    end)
                end)
                
                -- Add colorPicker to section's elements table
                table.insert(self.Elements, colorPicker)
                
                return colorPicker
            end
            
            -- Add section to tab's sections table
            table.insert(self.Sections, section)
            
            return section
        end
        
        -- Add tab to window's tabs table
        table.insert(self.Tabs, tab)
        
        -- Select this tab if it's the first one
        if #self.Tabs == 1 then
            self:SelectTab(tab)
        end
        
        return tab
    end
    
    -- Function to select a tab (show its content, hide others)
    function window:SelectTab(tab)
        -- First deselect current tab if there is one
        if self.CurrentTab then
            -- Update visual appearance
            Tween(self.CurrentTab.Button, {BackgroundColor3 = T.Theme.DarkContrast})
            
            -- Hide content
            self.CurrentTab.Container.Visible = false
        end
        
        -- Set new current tab
        self.CurrentTab = tab
        
        -- Update visual appearance
        Tween(tab.Button, {BackgroundColor3 = T.Theme.Accent})
        
        -- Show content
        tab.Container.Visible = true
    end
    
    -- Add window to library's windows table
    table.insert(self.Windows, window)
    
    return window
end

-- Return the library
return T
