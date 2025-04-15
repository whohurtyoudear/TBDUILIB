--[[
TBDLib - A modern, feature-rich Roblox UI library
Version: 2.0.0 (April 2025)

Cross-platform UI library specifically designed for script hubs and executors
Features improved mobile support and a wide layout design.

Recent improvements:
- Fixed dropdown layering - Dropdowns now appear above other UI elements
- Improved event handling with cross-platform compatibility
- Enhanced notification system with better customization
- Fixed UI toggle functionality - Now properly toggles UI visibility
- Enhanced mobile support with larger touch targets
- Added player info component with avatar and game stats
- Fixed SelectTab function for proper content visibility
- Added robust error handling throughout the codebase
]]

local TBDLib = {
Name = "TBDLib",
Version = "2.0.0",
Theme = {
-- Main Colors
Primary = Color3.fromRGB(28, 33, 54),       -- Main background
Secondary = Color3.fromRGB(35, 40, 60),     -- Section backgrounds
Tertiary = Color3.fromRGB(42, 48, 70),      -- UI element backgrounds
Background = Color3.fromRGB(25, 28, 45),    -- Outermost background

-- Accent Colors
Accent = Color3.fromRGB(113, 93, 196),      -- Main accent color
AccentDark = Color3.fromRGB(86, 70, 150),   -- Darker accent color
AccentLight = Color3.fromRGB(140, 120, 225),-- Lighter accent color

-- Status Colors
Success = Color3.fromRGB(68, 214, 125),     -- Success color
Warning = Color3.fromRGB(255, 170, 0),      -- Warning color 
Error = Color3.fromRGB(255, 80, 80),        -- Error color
Info = Color3.fromRGB(80, 170, 245),        -- Info color

-- Text Colors
Text = Color3.fromRGB(240, 240, 250),       -- Primary text color
TextDark = Color3.fromRGB(180, 180, 190),   -- Secondary text color
TextLight = Color3.fromRGB(255, 255, 255),  -- Bright text color
TextDisabled = Color3.fromRGB(140, 140, 150),-- Disabled text color

-- Misc
ControlBg = Color3.fromRGB(255, 255, 255),  -- Control elements
Border = Color3.fromRGB(50, 55, 75),        -- Border color
Divider = Color3.fromRGB(60, 65, 85),       -- Divider color
NotifBackground = Color3.fromRGB(35, 40, 60),-- Notif background
NotifText = Color3.fromRGB(240, 240, 250)   -- Notif text
},
Windows = {},
Flags = {},
ConfigSystem = {
Folder = "TBDLib",
CurrentConfig = "default",
AutoSave = true
},
Icons = {
-- Window controls
Close = "rbxassetid://11436284823",
Minimize = "rbxassetid://11436290535",
Maximize = "rbxassetid://11436293815",
Split = "rbxassetid://11436357091",
Restore = "rbxassetid://11436348454",

-- Navigation
Home = "rbxassetid://11482892823",
Settings = "rbxassetid://11482911926", 
Scripts = "rbxassetid://11482983864",
Hub = "rbxassetid://11482975131",
Plugins = "rbxassetid://11482999950",
Games = "rbxassetid://11483008454",
Search = "rbxassetid://11483028465",

-- UI Elements
Toggle = "rbxassetid://11482968672",
ToggleEnabled = "rbxassetid://11482969091",
Dropdown = "rbxassetid://11482971699",
Slider = "rbxassetid://11482993241",
ColorPicker = "rbxassetid://11483009289",
Checkbox = "rbxassetid://11483015967",
CheckboxChecked = "rbxassetid://11483016401",

-- Status Icons
Success = "rbxassetid://11483017272",
Warning = "rbxassetid://11483017830",
Error = "rbxassetid://11483018616",
Info = "rbxassetid://11483020604",

-- Player Icons
Avatar = "rbxassetid://7962146544",
Crown = "rbxassetid://7733955740",
People = "rbxassetid://7743866529",
Server = "rbxassetid://10889391188",
Globe = "rbxassetid://9405893280",
Clock = "rbxassetid://7733674079",

-- Misc Icons
Folder = "rbxassetid://11483033225",
File = "rbxassetid://11483033657",
Code = "rbxassetid://11483037364",
Bolt = "rbxassetid://11483038654",
Star = "rbxassetid://11483039206",
Key = "rbxassetid://11483040349",
Lock = "rbxassetid://11483040849",
Unlock = "rbxassetid://11483041299",
Clipboard = "rbxassetid://11483044588",
Copy = "rbxassetid://11483045117",
Notification = "rbxassetid://6031075699"
},
Animation = {
DefaultDuration = 0.25,
DefaultEasingStyle = Enum.EasingStyle.Quint,
DefaultEasingDirection = Enum.EasingDirection.Out
},
NotificationSettings = {
Position = "TopRight",     -- TopRight, TopLeft, BottomRight, BottomLeft
Duration = 3,              -- Default duration in seconds
Sound = true,              -- Play notification sound
SoundId = "rbxassetid://6518811702",
MaxNotifications = 5,      -- Maximum number of visible notifications
Style = "Modern"           -- Modern, Compact, Minimal
}
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")

-- Safe CoreGui reference (handles edge cases with executors)
local CoreGui
local PlayerGui

-- Try multiple methods to get a valid GUI parent
local function SafeGetGuiParent()
-- Method 1: Try standard CoreGui
local success1, coreGui = pcall(function()
return game:GetService("CoreGui")
end)

-- Method 2: Try getting the PlayerGui
local success2, playerGui = pcall(function()
return game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")
end)

-- Method 3: Try through gethui() (used by some executors)
local success3, gethuiGui = pcall(function()
return gethui and gethui() or nil
end)

-- Return the first successful method
if success1 and coreGui then
return coreGui, "CoreGui" 
elseif success3 and gethuiGui then
return gethuiGui, "gethui"
elseif success2 and playerGui then
return playerGui, "PlayerGui"
else
-- Fallback to a direct PlayerGui reference as last resort
local player = game:GetService("Players").LocalPlayer
if player and player:FindFirstChildOfClass("PlayerGui") then
return player:FindFirstChildOfClass("PlayerGui"), "FallbackPlayerGui"
end
end

-- If all else fails, return a warning and use CoreGui anyway
warn("TBDLib: Failed to get a valid GUI parent, using CoreGui as fallback")
return game:GetService("CoreGui"), "FallbackCoreGui"
end

-- Get the appropriate GUI parent
local guiParentType
CoreGui, guiParentType = SafeGetGuiParent()
PlayerGui = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui")

-- Variables
local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = Player:GetMouse()
local IsStudio = RunService:IsStudio()
local Connections = {}
local OpenFrames = {}
local NotificationCount = 0
local DraggingObject = nil
local ConfigFolder = TBDLib.ConfigSystem.Folder
local Ripples = {}

-- Constants
local TWEEN_INFO = TweenInfo.new(
TBDLib.Animation.DefaultDuration,
TBDLib.Animation.DefaultEasingStyle,
TBDLib.Animation.DefaultEasingDirection
)

-- Utility Functions
local function GetTextSize(Text, Size, Font, Resolution)
return TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1000, 1000))
end

local function Tween(Instance, Properties, Duration, Style, Direction, Callback)
local TweenInfo = TweenInfo.new(
Duration or TBDLib.Animation.DefaultDuration,
Style or TBDLib.Animation.DefaultEasingStyle,
Direction or TBDLib.Animation.DefaultEasingDirection
)

local Tween = TweenService:Create(Instance, TweenInfo, Properties)

if Callback then
Tween.Completed:Connect(function()
Callback()
end)
end

Tween:Play()
return Tween
end

local function Connect(Signal, Callback)
if not Signal then
warn("TBDLib: Attempted to connect to a nil signal")
return nil
end

local success, Connection = pcall(function()
return Signal:Connect(Callback)
end)

if success and Connection then
table.insert(Connections, Connection)
return Connection
else
warn("TBDLib: Failed to connect to signal: " .. tostring(Signal))
return nil
end
end

local function Disconnect(Connection)
for i, conn in ipairs(Connections) do
if conn == Connection then
conn:Disconnect()
table.remove(Connections, i)
break
end
end
end

local function DisconnectAll()
for _, Connection in ipairs(Connections) do
Connection:Disconnect()
end
Connections = {}
end

local function Create(ClassName, Properties)
local Instance = Instance.new(ClassName)

for Property, Value in pairs(Properties) do
if Property ~= "Parent" then
if typeof(Value) == "Instance" then
    Value.Parent = Instance
else
    Instance[Property] = Value
end
end
end

if Properties.Parent then
Instance.Parent = Properties.Parent
end

return Instance
end

local function MakeDraggable(DragObject, DragHandle)
DragHandle = DragHandle or DragObject

local Dragging = false
local DragInput
local DragStart
local StartPosition

local function Update(Input)
local Delta = Input.Position - DragStart
local NewPosition = UDim2.new(
StartPosition.X.Scale,
StartPosition.X.Offset + Delta.X,
StartPosition.Y.Scale,
StartPosition.Y.Offset + Delta.Y
)

Tween(DragObject, {Position = NewPosition}, 0.1)
end

Connect(DragHandle.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
Dragging = true
DragStart = Input.Position
StartPosition = DragObject.Position

Input.Changed:Connect(function()
    if Input.UserInputState == Enum.UserInputState.End then
        Dragging = false
    end
end)
end
end)

Connect(DragHandle.InputChanged, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
DragInput = Input
end
end)

Connect(UserInputService.InputChanged, function(Input)
if Input == DragInput and Dragging then
Update(Input)
end
end)

return {
Disconnect = function()
Dragging = false
DragInput = nil
DragStart = nil
StartPosition = nil
end
}
end

local function CreateRoundedFrame(Size, Position, Color, Parent, Corner, Name)
local Frame = Create("Frame", {
Name = Name or "RoundedFrame",
Size = Size or UDim2.new(1, 0, 1, 0),
Position = Position or UDim2.new(0, 0, 0, 0),
BackgroundColor3 = Color or TBDLib.Theme.Primary,
BorderSizePixel = 0,
ZIndex = Parent and (Parent.ZIndex or 1) + 1 or 5, -- Inherit parent's z-index if available
Parent = Parent
})

local UICorner = Create("UICorner", {
CornerRadius = UDim.new(0, Corner or 8),
Parent = Frame
})

return Frame
end

local function CreateShadow(Parent, Transparency, Offset)
local Shadow = Create("ImageLabel", {
Name = "Shadow",
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundTransparency = 1,
Position = UDim2.new(0.5, 0, 0.5, Offset or 4),
Size = UDim2.new(1, 12, 1, 12),
Image = "rbxassetid://11579303181",
ImageTransparency = Transparency or 0.5,
ImageColor3 = Color3.fromRGB(0, 0, 0),
ScaleType = Enum.ScaleType.Slice,
SliceCenter = Rect.new(20, 20, 280, 280),
Parent = Parent
})

return Shadow
end

local function CreateStroke(Parent, Color, Thickness, Transparency)
local Stroke = Create("UIStroke", {
Color = Color or TBDLib.Theme.Border,
Thickness = Thickness or 1,
Transparency = Transparency or 0,
ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
Parent = Parent
})

return Stroke
end

local function CreateGradient(Parent, Colors, Transparency, Rotation)
local Gradient = Create("UIGradient", {
Color = typeof(Colors) == "ColorSequence" and Colors or
ColorSequence.new({
    ColorSequenceKeypoint.new(0, Colors[1] or TBDLib.Theme.Accent),
    ColorSequenceKeypoint.new(1, Colors[2] or TBDLib.Theme.AccentDark)
}),
Transparency = typeof(Transparency) == "NumberSequence" and Transparency or 
NumberSequence.new(Transparency or 0),
Rotation = Rotation or 0,
Parent = Parent
})

return Gradient
end

local function CreateRipple(Parent)
local RippleContainer = Create("Frame", {
Name = "RippleContainer",
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundTransparency = 1,
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(1, 0, 1, 0),
ClipsDescendants = true,
Parent = Parent
})

Parent.ClipsDescendants = true

local function StartRipple(InputPosition)
local RippleCircle = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
BackgroundTransparency = 0.85,
Position = UDim2.new(0, InputPosition.X - Parent.AbsolutePosition.X, 0, InputPosition.Y - Parent.AbsolutePosition.Y),
Size = UDim2.new(0, 0, 0, 0),
Parent = RippleContainer
})

Create("UICorner", {
CornerRadius = UDim.new(1, 0),
Parent = RippleCircle
})

local MaxSize = math.max(Parent.AbsoluteSize.X, Parent.AbsoluteSize.Y) * 2

Tween(RippleCircle, {
Size = UDim2.new(0, MaxSize, 0, MaxSize),
BackgroundTransparency = 1
}, 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
RippleCircle:Destroy()
end)
end

Connect(Parent.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
StartRipple(Input.Position)
end
end)

table.insert(Ripples, RippleContainer)
return RippleContainer
end

local function DeepCopy(Original)
local Copy = {}
for Key, Value in pairs(Original) do
if type(Value) == "table" then
Copy[Key] = DeepCopy(Value)
else
Copy[Key] = Value
end
end
return Copy
end

local function CleanName(String)
return String:gsub("[^%w%s]", ""):gsub("%s+", "_"):lower()
end

local function SaveConfig(Name)
if not isfolder then return false end

Name = Name or TBDLib.ConfigSystem.CurrentConfig

if not isfolder(ConfigFolder) then
makefolder(ConfigFolder)
end

local Config = {}
for Flag, Value in pairs(TBDLib.Flags) do
if type(Value) == "table" and Value.Value ~= nil then
-- For objects with a value property (like toggles, sliders, etc.)
if type(Value.Value) ~= "function" and type(Value.Value) ~= "userdata" then
    Config[Flag] = Value.Value
end
else
-- For direct values
if type(Value) ~= "function" and type(Value) ~= "userdata" then
    Config[Flag] = Value
end
end
end

local Success, Result = pcall(function()
return HttpService:JSONEncode(Config)
end)

if Success then
writefile(ConfigFolder .. "/" .. Name .. ".json", Result)
return true
end

return false
end

local function LoadConfig(Name)
if not isfile then return false end

Name = Name or TBDLib.ConfigSystem.CurrentConfig
local Path = ConfigFolder .. "/" .. Name .. ".json"

if isfile(Path) then
local Success, Result = pcall(function()
return HttpService:JSONDecode(readfile(Path))
end)

if Success then
for Flag, Value in pairs(Result) do
    if TBDLib.Flags[Flag] then
        if type(TBDLib.Flags[Flag]) == "table" and TBDLib.Flags[Flag].Set then
            -- For objects with a Set method
            TBDLib.Flags[Flag]:Set(Value)
        else
            -- For direct values
            TBDLib.Flags[Flag] = Value
        end
    end
end
return true
end
end

return false
end

-- UI Visibility Toggle
local UIVisible = true

function TBDLib:ToggleUI()
UIVisible = not UIVisible

local UIContainer = CoreGui:FindFirstChild("TBDLibContainer")
if UIContainer then
    -- Use Tween for smoother transitions
    if UIVisible then
        UIContainer.Enabled = true
        for _, child in pairs(UIContainer:GetDescendants()) do
            if child:IsA("GuiObject") and child.Name ~= "Shadow" then
                if not child:GetAttribute("DefaultTransparency") then
                    child:SetAttribute("DefaultTransparency", child.BackgroundTransparency)
                end
                child.BackgroundTransparency = 1
                Tween(child, {BackgroundTransparency = child:GetAttribute("DefaultTransparency") or 0}, 0.3)
            end
        end
    else
        for _, child in pairs(UIContainer:GetDescendants()) do
            if child:IsA("GuiObject") and child.Name ~= "Shadow" then
                -- Store default transparency if not already stored
                if not child:GetAttribute("DefaultTransparency") then
                    child:SetAttribute("DefaultTransparency", child.BackgroundTransparency)
                end
                Tween(child, {BackgroundTransparency = 1}, 0.3, nil, nil, function()
                    if not UIVisible then
                        UIContainer.Enabled = false
                    end
                end)
            end
        end
    end
end

return UIVisible
end

-- Get Player & Game Info
function TBDLib:GetPlayerInfo()
local Info = {
Player = {
Name = Player.Name,
DisplayName = Player.DisplayName,
UserId = Player.UserId,
AccountAge = Player.AccountAge,
MembershipType = tostring(Player.MembershipType),
Avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=420&height=420&format=png"
},
Game = {
Name = "Game",
PlaceId = game.PlaceId,
PlaceVersion = game.PlaceVersion,
JobId = game.JobId
},
Server = {
Players = #Players:GetPlayers(),
MaxPlayers = Players.MaxPlayers,
Ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()),
Uptime = os.time()
}
}

pcall(function()
Info.Game.Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

return Info
end

-- Create notification close function ahead of time to avoid nil references
local function CloseNotification(NotifFrame)
if NotifFrame and NotifFrame:IsA("GuiObject") then
Tween(NotifFrame, {
BackgroundTransparency = 1,
Position = UDim2.new(1, 0, 0, NotifFrame.Position.Y.Offset)
}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
if NotifFrame and NotifFrame.Parent then
    NotifFrame:Destroy()
end
end)
end
end

-- Notification System
local NotificationHolder

function TBDLib:Notify(Title, Message, Duration, Type)
Type = Type or "Info"
Duration = Duration or 5

-- Safety check for function parameters
if type(Title) ~= "string" then Title = tostring(Title) or "Notification" end
if type(Message) ~= "string" then Message = tostring(Message) or "" end
if type(Duration) ~= "number" then Duration = 5 end

-- Ensure we have a valid container for notifications
local container

-- Ensure TBDLibContainer exists with reliable error handling
local success = pcall(function()
container = CoreGui:FindFirstChild("TBDLibContainer")
end)

if not success or not container then
-- Create the container if it doesn't exist
local newContainerSuccess, newContainer = pcall(function()
local tempContainer = Create("ScreenGui", {
    Name = "TBDLibContainer",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Set parent based on environment with error handling
if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
    syn.protect_gui(tempContainer)
    tempContainer.Parent = CoreGui
elseif typeof(gethui) == "function" then
    tempContainer.Parent = gethui()
elseif typeof(PlayerGui) == "Instance" then
    tempContainer.Parent = PlayerGui
else
    tempContainer.Parent = CoreGui
end

return tempContainer
end)

if newContainerSuccess then
container = newContainer
else
-- If we still can't create a container, we need to bail out
warn("TBDLib: Failed to create notification container")
return nil
end
end

-- Validate NotificationHolder with error handling
if not NotificationHolder or not NotificationHolder.Parent then
local holderSuccess, newHolder = pcall(function()
-- Create the notification container if it doesn't exist
local tempHolder = Create("Frame", {
    Name = "NotificationHolder",
    AnchorPoint = Vector2.new(1, 0),
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 300, 1, -40),
    Parent = container
})

local UIListLayout = Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Parent = tempHolder
})

return tempHolder
end)

if holderSuccess then
NotificationHolder = newHolder
else
-- If we can't create the holder, bail out
warn("TBDLib: Failed to create notification holder")
return nil
end
end

NotificationCount = NotificationCount + 1
local ID = NotificationCount

-- Determine the notification color and icon based on type
local TypeInfo = {
Info = {
Color = TBDLib.Theme.Info,
Icon = TBDLib.Icons.Info
},
Success = {
Color = TBDLib.Theme.Success,
Icon = TBDLib.Icons.Success
},
Warning = {
Color = TBDLib.Theme.Warning,
Icon = TBDLib.Icons.Warning
},
Error = {
Color = TBDLib.Theme.Error,
Icon = TBDLib.Icons.Error
}
}

local Info = TypeInfo[Type] or TypeInfo.Info

-- Create the notification frame
local NotifFrame = CreateRoundedFrame(
UDim2.new(1, 0, 0, 0),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Secondary,
NotificationHolder,
8,
"Notification_" .. ID
)

NotifFrame.AutomaticSize = Enum.AutomaticSize.Y
NotifFrame.LayoutOrder = ID
NotifFrame.BackgroundTransparency = 1
NotifFrame.Size = UDim2.new(1, 0, 0, 0)

-- Create the inner content frame
local ContentFrame = CreateRoundedFrame(
UDim2.new(1, 0, 0, 0),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Secondary,
NotifFrame,
8,
"Content"
)
ContentFrame.AutomaticSize = Enum.AutomaticSize.Y

-- Add a shadow for depth
CreateShadow(ContentFrame, 0.5)

-- Create accent indicator
local AccentBar = CreateRoundedFrame(
UDim2.new(0, 4, 1, -16),
UDim2.new(0, 8, 0, 8),
Info.Color,
ContentFrame,
2,
"AccentBar"
)

-- Add icon
local IconBackground = CreateRoundedFrame(
UDim2.new(0, 32, 0, 32),
UDim2.new(0, 20, 0, 12),
Info.Color,
ContentFrame,
8,
"IconBackground"
)

local Icon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundTransparency = 1,
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 18, 0, 18),
Image = Info.Icon,
Parent = IconBackground
})

-- Add title
local TitleLabel = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.new(0, 64, 0, 12),
Size = UDim2.new(1, -84, 0, 20),
Font = Enum.Font.GothamBold,
Text = Title or "Notification",
TextColor3 = TBDLib.Theme.Text,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = ContentFrame
})

-- Add message
local MessageLabel = Create("TextLabel", {
Name = "Message",
BackgroundTransparency = 1,
Position = UDim2.new(0, 64, 0, 36),
Size = UDim2.new(1, -84, 0, 0),
Font = Enum.Font.Gotham,
Text = Message or "",
TextColor3 = TBDLib.Theme.TextDark,
TextSize = 13,
TextWrapped = true,
TextXAlignment = Enum.TextXAlignment.Left,
TextYAlignment = Enum.TextYAlignment.Top,
AutomaticSize = Enum.AutomaticSize.Y,
ClipsDescendants = false, -- Allow text to flow outside the container for automatic sizing
Parent = ContentFrame
})

-- Add padding at the bottom
local BottomPadding = Create("Frame", {
Name = "BottomPadding",
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, 0, 0, 12),
AnchorPoint = Vector2.new(0, 0),
Parent = MessageLabel
})
BottomPadding.LayoutOrder = 999999

-- Create a close button
local CloseButton = Create("ImageButton", {
Name = "CloseButton",
AnchorPoint = Vector2.new(1, 0),
BackgroundTransparency = 1,
Position = UDim2.new(1, -12, 0, 12),
Size = UDim2.new(0, 16, 0, 16),
Image = TBDLib.Icons.Close,
ImageColor3 = TBDLib.Theme.TextDark,
Parent = ContentFrame
})

Connect(CloseButton.MouseEnter, function()
Tween(CloseButton, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
end)

Connect(CloseButton.MouseLeave, function()
Tween(CloseButton, {ImageColor3 = TBDLib.Theme.TextDark}, 0.2)
end)

-- Add button click handling with redundancy for cross-platform support
local CloseNotificationFunction = function()
CloseNotification(NotifFrame)
end

-- Connect to InputBegan instead of MouseButton1Click for better mobile compatibility
Connect(CloseButton.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
CloseNotificationFunction()
end
end)

-- For compatibility with platforms that properly support MouseButton1Click
pcall(function()
Connect(CloseButton.MouseButton1Click, CloseNotificationFunction)
end)

-- Add progress bar
local ProgressBarBackground = CreateRoundedFrame(
UDim2.new(1, -32, 0, 3),
UDim2.new(0, 16, 1, -8),
TBDLib.Theme.Border,
ContentFrame,
2,
"ProgressBackground"
)

local ProgressBar = CreateRoundedFrame(
UDim2.new(1, 0, 1, 0),
UDim2.new(0, 0, 0, 0),
Info.Color,
ProgressBarBackground,
2,
"ProgressBar"
)

-- Animate the notification appearance
NotifFrame.Size = UDim2.new(1, 0, 0, 0)
Tween(NotifFrame, {BackgroundTransparency = 0}, 0.3)

-- Animate progress bar
Tween(ProgressBar, {Size = UDim2.new(0, 0, 1, 0)}, Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, function()
if NotifFrame and NotifFrame.Parent then
CloseNotification(NotifFrame)
end
end)

return NotifFrame
end

-- Window Constructor
function TBDLib:CreateWindow(Config)
Config = Config or {}

-- Default configuration
local WindowConfig = {
Title = Config.Title or "TBDLib",
Size = Config.Size or {Width = 1000, Height = 600},
MinSize = Config.MinSize or {Width = 700, Height = 400},
Theme = Config.Theme or TBDLib.Theme,
Position = Config.Position,
Center = Config.Center == nil and true or Config.Center,
AutoSave = Config.AutoSave == nil and true or Config.AutoSave,
SaveConfig = Config.SaveConfig or "default",
Discord = Config.Discord,
Icon = Config.Icon
}

-- Update theme if custom theme is provided
if Config.Theme then
for Key, Value in pairs(Config.Theme) do
TBDLib.Theme[Key] = Value
end
end

-- Set current config name
TBDLib.ConfigSystem.CurrentConfig = WindowConfig.SaveConfig

-- Create main GUI container if it doesn't exist
local GUI

if not CoreGui:FindFirstChild("TBDLibContainer") then
local Container = Create("ScreenGui", {
Name = "TBDLibContainer",
ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})

-- Set parent based on environment
if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
syn.protect_gui(Container)
Container.Parent = CoreGui
elseif typeof(gethui) == "function" then
Container.Parent = gethui()
elseif typeof(PlayerGui) == "Instance" then
Container.Parent = PlayerGui
else
Container.Parent = CoreGui
end

GUI = Container
else
GUI = CoreGui:FindFirstChild("TBDLibContainer")
end

-- Calculate window size and position
local ScreenSize = workspace.CurrentCamera.ViewportSize
local WindowSize = UDim2.new(
0, 
math.clamp(WindowConfig.Size.Width, WindowConfig.MinSize.Width, ScreenSize.X - 100), 
0, 
math.clamp(WindowConfig.Size.Height, WindowConfig.MinSize.Height, ScreenSize.Y - 100)
)

local WindowPosition
if WindowConfig.Center then
WindowPosition = UDim2.new(0.5, -WindowSize.X.Offset / 2, 0.5, -WindowSize.Y.Offset / 2)
else
WindowPosition = WindowConfig.Position or UDim2.new(0.5, -WindowSize.X.Offset / 2, 0.5, -WindowSize.Y.Offset / 2)
end

-- Create window frame
local WindowFrame = CreateRoundedFrame(
WindowSize,
WindowPosition,
TBDLib.Theme.Background,
GUI,
10,
"WindowFrame"
)

local Shadow = CreateShadow(WindowFrame, 0.4, 8)

-- Create main container
local WindowContainer = CreateRoundedFrame(
UDim2.new(1, -2, 1, -2),
UDim2.new(0, 1, 0, 1),
TBDLib.Theme.Primary,
WindowFrame,
10,
"WindowContainer"
)

-- Create top bar
local TopBar = CreateRoundedFrame(
UDim2.new(1, 0, 0, 40),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Secondary,
WindowContainer,
10,
"TopBar"
)

-- Apply corner masking for top corners only 
local TopLeftCorner = Create("Frame", {
Name = "TopLeftCorner",
Size = UDim2.new(0, 10, 0, 10),
Position = UDim2.new(0, 0, 0, 0),
BorderSizePixel = 0,
BackgroundColor3 = TBDLib.Theme.Secondary,
Parent = TopBar
})

local TopRightCorner = Create("Frame", {
Name = "TopRightCorner",
Size = UDim2.new(0, 10, 0, 10),
Position = UDim2.new(1, -10, 0, 0),
BorderSizePixel = 0,
BackgroundColor3 = TBDLib.Theme.Secondary,
Parent = TopBar
})

-- Fix for square corner in top bar
local BottomMask = Create("Frame", {
Name = "BottomMask",
Size = UDim2.new(1, 0, 0, 10),
Position = UDim2.new(0, 0, 1, -10),
BorderSizePixel = 0,
BackgroundColor3 = TBDLib.Theme.Secondary,
Parent = TopBar
})

-- Add window title
local TitleText = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.new(0, 15, 0, 0),
Size = UDim2.new(0.5, -15, 1, 0),
Font = Enum.Font.GothamBold,
Text = WindowConfig.Title,
TextColor3 = TBDLib.Theme.Text,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = TopBar
})

-- Add window icon if provided
if WindowConfig.Icon then
local Icon = Create("ImageLabel", {
Name = "Icon",
BackgroundTransparency = 1,
Position = UDim2.new(0, 15, 0.5, -8),
Size = UDim2.new(0, 16, 0, 16),
Image = WindowConfig.Icon,
Parent = TopBar
})

TitleText.Position = UDim2.new(0, 40, 0, 0)
end

-- Create window controls
local ControlsContainer = Create("Frame", {
Name = "Controls",
AnchorPoint = Vector2.new(1, 0),
BackgroundTransparency = 1,
Position = UDim2.new(1, -10, 0, 8),
Size = UDim2.new(0, 84, 0, 24),
Parent = TopBar
})

-- Create control buttons
local function CreateControlButton(Name, Icon, Position)
local ControlButton = CreateRoundedFrame(
UDim2.new(0, 24, 0, 24),
UDim2.new(1, Position, 0, 0),
TBDLib.Theme.Primary,
ControlsContainer,
6,
Name .. "Button"
)
ControlButton.ZIndex = 20 -- Higher z-index for better visibility

local ButtonIcon = Create("ImageLabel", {
Name = "Icon",
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundTransparency = 1,
Position = UDim2.new(0.5, 0, 0.5, 0),
Size = UDim2.new(0, 14, 0, 14), -- Slightly larger icon size
Image = Icon,
ImageColor3 = TBDLib.Theme.TextDark,
ZIndex = 21, -- Higher than parent
Parent = ControlButton
})

-- Force the image to load properly
ButtonIcon:GetPropertyChangedSignal("IsLoaded"):Connect(function()
    if not ButtonIcon.IsLoaded then return end
    ButtonIcon.ImageColor3 = TBDLib.Theme.TextDark
end)

local Background = CreateRoundedFrame(
UDim2.new(1, 0, 1, 0),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Primary,
ControlButton,
6,
Name .. "Background"
)
Background.BackgroundTransparency = 1
Background.ZIndex = 19 -- Lower than button but higher than most UI

return ControlButton, Background
end

-- Close button
local CloseButton, CloseBackground = CreateControlButton("Close", TBDLib.Icons.Close, -24)

-- Minimize button
local MinimizeButton, MinimizeBackground = CreateControlButton("Minimize", TBDLib.Icons.Minimize, -54)

-- Maximize/Restore button
local MaximizeButton, MaximizeBackground = CreateControlButton("Maximize", TBDLib.Icons.Maximize, -84)

-- Window state variables
local Minimized = false
local Maximized = false
local OriginalSize = WindowSize
local OriginalPosition = WindowPosition

-- Button hover effects
local function SetupButtonHover(Button, Background, HoverColor, LeaveColor)
Connect(Button.MouseEnter, function()
Tween(Background, {BackgroundTransparency = 0.8}, 0.2)
Tween(Button.Icon, {ImageColor3 = HoverColor}, 0.2)
end)

Connect(Button.MouseLeave, function()
Tween(Background, {BackgroundTransparency = 1}, 0.2)
Tween(Button.Icon, {ImageColor3 = LeaveColor}, 0.2)
end)
end

-- Set up hover effects
SetupButtonHover(CloseButton, CloseBackground, Color3.fromRGB(255, 80, 80), TBDLib.Theme.TextDark)
SetupButtonHover(MinimizeButton, MinimizeBackground, TBDLib.Theme.Text, TBDLib.Theme.TextDark)
SetupButtonHover(MaximizeButton, MaximizeBackground, TBDLib.Theme.Text, TBDLib.Theme.TextDark)

-- Close button click handler
local CloseWindowFunction = function()
-- Save config if auto-save is enabled
if WindowConfig.AutoSave then
SaveConfig()
end

-- Tween window out
Tween(WindowFrame, {
Size = UDim2.new(WindowFrame.Size.X.Scale, WindowFrame.Size.X.Offset, 0, 0),
Position = UDim2.new(WindowFrame.Position.X.Scale, WindowFrame.Position.X.Offset, WindowFrame.Position.Y.Scale, WindowFrame.Position.Y.Offset + WindowFrame.Size.Y.Offset / 2)
}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
WindowFrame:Destroy()
end)
end

-- Connect to button's InputBegan instead of MouseButton1Click for better mobile compatibility
Connect(CloseButton.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
CloseWindowFunction()
end
end)

-- For compatibility with platforms that properly support MouseButton1Click
pcall(function()
Connect(CloseButton.MouseButton1Click, CloseWindowFunction)
Connect(CloseBackground.MouseButton1Click, CloseWindowFunction)
end)

-- Minimize button click handler
local MinimizedHeight = 40 -- Just the top bar
local function ToggleMinimize()
Minimized = not Minimized

if Minimized then
    -- Store the original size if not minimized and not maximized
    if not Maximized then
        OriginalSize = WindowFrame.Size
        OriginalPosition = WindowFrame.Position
    end
    
    -- Minimize animation with proper content hiding
    Tween(WindowFrame, {
        Size = UDim2.new(WindowFrame.Size.X.Scale, WindowFrame.Size.X.Offset, 0, MinimizedHeight)
    }, 0.3, nil, nil, function()
        -- After animation completes, hide the content to prevent showing through
        ContentFrame.Visible = false
    end)
else
    -- First make content visible again
    ContentFrame.Visible = true
    
    -- Restore to appropriate size
    if Maximized then
        -- Restore to maximized size (full screen)
        local MaxSize = UDim2.new(1, 0, 1, -36) -- Account for taskbar
        Tween(WindowFrame, {
            Size = MaxSize,
            Position = UDim2.new(0, 0, 0, 0)
        }, 0.3)
    else
        -- Restore to original size
        Tween(WindowFrame, {
            Size = OriginalSize,
            Position = OriginalPosition
        }, 0.3)
    end
end
end

-- Use pcall for MouseButton1Click connections to avoid errors on platforms where it's not supported
pcall(function()
Connect(MinimizeButton.MouseButton1Click, ToggleMinimize)
Connect(MinimizeBackground.MouseButton1Click, ToggleMinimize)
end)

-- Also connect to InputBegan for better cross-platform support
Connect(MinimizeButton.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
ToggleMinimize()
end
end)

-- Maximize/Restore button click handler
local function ToggleMaximize()
Maximized = not Maximized

if Maximized then
-- Store the original size before maximizing if not already minimized
if not Minimized then
    OriginalSize = WindowFrame.Size
    OriginalPosition = WindowFrame.Position
end

-- Switch to split screen icon
MaximizeButton.Icon.Image = TBDLib.Icons.Split

-- Maximize animation
Tween(WindowFrame, {
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0)
}, 0.3)
else
-- Switch back to maximize icon
MaximizeButton.Icon.Image = TBDLib.Icons.Maximize

-- Restore to original size and position
Tween(WindowFrame, {
    Size = OriginalSize,
    Position = OriginalPosition
}, 0.3)
end

-- Force minimized state to false when maximizing/restoring
Minimized = false
end

-- Use pcall for MouseButton1Click connections to avoid errors on platforms where it's not supported
pcall(function()
Connect(MaximizeButton.MouseButton1Click, ToggleMaximize)
Connect(MaximizeBackground.MouseButton1Click, ToggleMaximize)
end)

-- Also connect to InputBegan for better cross-platform support
Connect(MaximizeButton.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
ToggleMaximize()
end
end)

-- Make TopBar draggable with bounds checking
MakeDraggable(WindowFrame, TopBar)

-- Create content container with sidebar and main content
local ContentFrame = CreateRoundedFrame(
UDim2.new(1, 0, 1, -40),
UDim2.new(0, 0, 0, 40),
TBDLib.Theme.Primary,
WindowContainer,
8,
"ContentFrame"
)

-- Add sidebar for navigation
local Sidebar = CreateRoundedFrame(
UDim2.new(0, 50, 1, 0),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Secondary,
ContentFrame,
8,
"Sidebar"
)

-- Fix square corner in sidebar
local RightMask = Create("Frame", {
Name = "RightMask",
Size = UDim2.new(0, 10, 1, 0),
Position = UDim2.new(1, -10, 0, 0),
BorderSizePixel = 0,
BackgroundColor3 = TBDLib.Theme.Secondary,
Parent = Sidebar
})

-- Add sidebar navigation
local NavContainer = Create("Frame", {
Name = "NavContainer",
BackgroundTransparency = 1,
Position = UDim2.new(0, 5, 0, 10),
Size = UDim2.new(1, -10, 1, -20),
Parent = Sidebar
})

local NavList = Create("UIListLayout", {
Padding = UDim.new(0, 10),
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = NavContainer
})

-- Create tab container
local TabContainer = CreateRoundedFrame(
UDim2.new(1, -60, 1, -10),
UDim2.new(0, 55, 0, 5),
TBDLib.Theme.Secondary,
ContentFrame,
8,
"TabContainer"
)

-- Window API
local WindowAPI = {}
local Tabs = {}
local ActiveTab = nil

-- Add Tab
function WindowAPI:AddTab(TabConfig)
TabConfig = TabConfig or {}
local TabName = TabConfig.Name or "Tab"
local TabIcon = TabConfig.Icon
local TabOrder = TabConfig.Order or (#Tabs + 1)

local TabId = #Tabs + 1

-- Create tab button in sidebar
local NavButton = CreateRoundedFrame(
UDim2.new(1, 0, 0, 40),
nil,
ActiveTab == TabId and TBDLib.Theme.Accent or TBDLib.Theme.Primary,
NavContainer,
8,
"TabButton_" .. TabId
)
NavButton.LayoutOrder = TabOrder
NavButton.ZIndex = 10 -- Ensure proper z-index for visibility

-- Add icon if specified
if TabIcon then
local Icon = Create("ImageLabel", {
    Name = "Icon",
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.5, -6),
    Size = UDim2.new(0, 22, 0, 22), -- Slightly larger for better visibility
    Image = TabIcon,
    ImageColor3 = ActiveTab == TabId and TBDLib.Theme.TextLight or TBDLib.Theme.TextDark,
    ZIndex = NavButton.ZIndex + 1, -- Higher than parent for proper layering
    Parent = NavButton
})

-- Force the image to load and render properly
Icon:GetPropertyChangedSignal("IsLoaded"):Connect(function()
    if not Icon.IsLoaded then return end
    Icon.ImageColor3 = ActiveTab == TabId and TBDLib.Theme.TextLight or TBDLib.Theme.TextDark
end)
end

-- Add title
local TabTitle = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = TabIcon and UDim2.new(0, 0, 0.5, 14) or UDim2.new(0, 0, 0, 0),
Size = TabIcon and UDim2.new(1, 0, 0, 16) or UDim2.new(1, 0, 1, 0),
Font = Enum.Font.GothamBold,
Text = TabName,
TextColor3 = ActiveTab == TabId and TBDLib.Theme.TextLight or TBDLib.Theme.TextDark,
TextSize = 10,
Parent = NavButton
})

-- Indicator (for active tab)
local Indicator = CreateRoundedFrame(
UDim2.new(0, 4, 0, 20),
UDim2.new(0, 0, 0.5, -10),
TBDLib.Theme.Accent,
NavButton,
2,
"Indicator"
)
Indicator.BackgroundTransparency = 1

-- Tab content frame - with error handling to ensure it's created properly
local TabContentFrame
local success, err = pcall(function()
TabContentFrame = CreateRoundedFrame(
    UDim2.new(1, 0, 1, 0),
    nil,
    TBDLib.Theme.Secondary,
    TabContainer,
    8,
    "TabContent_" .. TabId
)
-- Only set to invisible if we're not on the first tab
TabContentFrame.Visible = (TabId == 1)
-- Ensure the frame is properly configured and has correct z-index
TabContentFrame.ZIndex = 5
TabContentFrame.ClipsDescendants = true
end)

if not success then
warn("TBDLib: Failed to create TabContentFrame - " .. tostring(err))
-- Create a recovery frame if primary creation fails
TabContentFrame = Create("Frame", {
    Name = "TabContent_" .. TabId,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundColor3 = TBDLib.Theme.Secondary,
    BorderSizePixel = 0,
    Visible = false,
    Parent = TabContainer
})

-- Add rounded corners
local UICorner = Create("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = TabContentFrame
})
end

-- Create a scrolling frame for the content
local ScrollingContent = Create("ScrollingFrame", {
Name = "ScrollingContent",
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, 0, 1, 0),
CanvasSize = UDim2.new(0, 0, 0, 0),
ScrollBarThickness = 0,
ScrollingDirection = Enum.ScrollingDirection.Y,
AutomaticCanvasSize = Enum.AutomaticSize.Y,
ClipsDescendants = true,
Parent = TabContentFrame
})

local ContentPadding = Create("UIPadding", {
PaddingLeft = UDim.new(0, 15),
PaddingRight = UDim.new(0, 15),
PaddingTop = UDim.new(0, 15),
PaddingBottom = UDim.new(0, 15),
Parent = ScrollingContent
})

local ContentList = Create("UIListLayout", {
Padding = UDim.new(0, 15),
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = ScrollingContent
})

-- Make ripple effect on nav button
CreateRipple(NavButton)

-- Create tab button
local TabButton = Create("TextButton", {
Name = "TabButton",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
Text = "",
Parent = NavButton
})

-- Tab button click handler with cross-platform compatibility
-- First use InputBegan for better compatibility
Connect(TabButton.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
    WindowAPI:SelectTab(TabId)
end
end)

-- Also try MouseButton1Click for redundancy
pcall(function()
Connect(TabButton.MouseButton1Click, function()
    WindowAPI:SelectTab(TabId)
end)
end)

-- Hover effects
Connect(TabButton.MouseEnter, function()
if ActiveTab ~= TabId then
    Tween(NavButton, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
    Tween(TabTitle, {TextColor3 = TBDLib.Theme.Text}, 0.2)
    if TabIcon then
        Tween(NavButton.Icon, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
    end
end
end)

Connect(TabButton.MouseLeave, function()
if ActiveTab ~= TabId then
    Tween(NavButton, {BackgroundColor3 = TBDLib.Theme.Primary}, 0.2)
    Tween(TabTitle, {TextColor3 = TBDLib.Theme.TextDark}, 0.2)
    if TabIcon then
        Tween(NavButton.Icon, {ImageColor3 = TBDLib.Theme.TextDark}, 0.2)
    end
end
end)

-- Store the tab
local Tab = {
Name = TabName,
Id = TabId,
Button = NavButton,
Content = TabContentFrame,
ScrollingContent = ScrollingContent
}

Tabs[TabId] = Tab

-- Tab API
local TabAPI = {}

function TabAPI:AddSection(SectionConfig)
SectionConfig = SectionConfig or {}
local SectionName = SectionConfig.Name or "Section"
local SectionId = CleanName(SectionName)

-- Create section frame
local SectionFrame = CreateRoundedFrame(
    UDim2.new(1, 0, 0, 0),
    nil,
    TBDLib.Theme.Tertiary,
    ScrollingContent,
    8,
    "Section_" .. SectionId
)
SectionFrame.AutomaticSize = Enum.AutomaticSize.Y

-- Set section order if specified
if SectionConfig.Order then
    SectionFrame.LayoutOrder = SectionConfig.Order
end

-- Create section header
local SectionHeader = Create("Frame", {
    Name = "SectionHeader",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0, 30),
    Parent = SectionFrame
})

local SectionTitle = Create("TextLabel", {
    Name = "SectionTitle",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 0),
    Size = UDim2.new(1, -24, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = SectionName,
    TextColor3 = TBDLib.Theme.Text,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = SectionHeader
})

-- Create section content area
local SectionContent = Create("Frame", {
    Name = "SectionContent",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(1, 0, 0, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    Parent = SectionFrame
})

-- Add padding and layout
local ContentPadding = Create("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingBottom = UDim.new(0, 12),
    Parent = SectionContent
})

local ContentList = Create("UIListLayout", {
    Padding = UDim.new(0, 10),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = SectionContent
})

-- Section API
local SectionAPI = {}

-- Add Label
function SectionAPI:AddLabel(Config)
    Config = Config or {}
    local LabelText = Config.Text or "Label"

    local LabelFrame = Create("Frame", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        LabelFrame.LayoutOrder = Config.Order
    end

    local TextLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.Gotham,
        Text = LabelText,
        TextColor3 = Config.Color or TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Config.Alignment or Enum.TextXAlignment.Left,
        Parent = LabelFrame
    })

    -- Label API
    local LabelAPI = {}

    function LabelAPI:SetText(NewText)
        TextLabel.Text = NewText
    end

    function LabelAPI:SetColor(NewColor)
        Tween(TextLabel, {TextColor3 = NewColor}, 0.2)
    end

    return LabelAPI
end

-- Add Button
function SectionAPI:AddButton(Config)
    Config = Config or {}
    local ButtonText = Config.Text or "Button"
    local ButtonCallback = Config.Callback or function() end

    local ButtonFrame = Create("Frame", {
        Name = "Button",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        ButtonFrame.LayoutOrder = Config.Order
    end

    local Button = CreateRoundedFrame(
        UDim2.new(1, 0, 1, 0),
        nil,
        Config.Color or TBDLib.Theme.Accent,
        ButtonFrame,
        6
    )

    local ButtonLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = ButtonText,
        TextColor3 = TBDLib.Theme.TextLight,
        TextSize = 14,
        Parent = Button
    })

    local ButtonButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = Button
    })

    -- Add ripple effect
    CreateRipple(Button)

    -- Button hover effects
    Connect(ButtonButton.MouseEnter, function()
        Tween(Button, {BackgroundColor3 = Config.HoverColor or TBDLib.Theme.AccentLight}, 0.2)
    end)

    Connect(ButtonButton.MouseLeave, function()
        Tween(Button, {BackgroundColor3 = Config.Color or TBDLib.Theme.Accent}, 0.2)
    end)

    -- Button click effects with improved cross-platform handling
    local function handleButtonPress()
        Tween(Button, {BackgroundColor3 = Config.PressColor or TBDLib.Theme.AccentDark}, 0.1)
    end

    local function handleButtonRelease()
        Tween(Button, {BackgroundColor3 = Config.HoverColor or TBDLib.Theme.AccentLight}, 0.1)
    end

    local function executeCallback()
        -- Use pcall to prevent callback errors from breaking the UI
        pcall(function()
            task.spawn(ButtonCallback)
        end)
    end

    -- Mouse down event
    Connect(ButtonButton.MouseButton1Down, handleButtonPress)

    -- Also try InputBegan for better touch support
    Connect(ButtonButton.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            handleButtonPress()

            -- For touch events, we need to track when the input ends to simulate button release
            if Input.UserInputType == Enum.UserInputType.Touch then
                local connection
                connection = Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        handleButtonRelease()
                        executeCallback()
                        -- Cleanup the temporary connection
                        if connection then
                            connection:Disconnect()
                            connection = nil
                        end
                    end
                end)
            end
        end
    end)

    -- Mouse up event
    Connect(ButtonButton.MouseButton1Up, function()
        handleButtonRelease()
    end)

    -- Traditional click event (works on most platforms)
    Connect(ButtonButton.MouseButton1Click, executeCallback)

    -- Input ended for mobile platforms
    Connect(ButtonButton.InputEnded, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- We handle touch release separately through the Changed event above
            executeCallback()
        end
    end)

    -- Button API
    local ButtonAPI = {}

    function ButtonAPI:SetText(NewText)
        ButtonLabel.Text = NewText
    end

    function ButtonAPI:SetCallback(NewCallback)
        ButtonCallback = NewCallback
    end

    return ButtonAPI
end

-- Add Toggle
function SectionAPI:AddToggle(Config)
    Config = Config or {}
    local ToggleText = Config.Text or "Toggle"
    local ToggleCallback = Config.Callback or function() end
    local ToggleFlag = Config.Flag
    local ToggleDefault = Config.Default or false

    local ToggleFrame = Create("Frame", {
        Name = "Toggle",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        ToggleFrame.LayoutOrder = Config.Order
    end

    local ToggleLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = Enum.Font.Gotham,
        Text = ToggleText,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = ToggleFrame
    })

    local ToggleBackground = CreateRoundedFrame(
        UDim2.new(0, 36, 0, 20),
        UDim2.new(1, -42, 0.5, -10),
        TBDLib.Theme.Border,
        ToggleFrame,
        10
    )

    local ToggleIndicator = CreateRoundedFrame(
        UDim2.new(0, 16, 0, 16),
        UDim2.new(0, 2, 0.5, -8),
        TBDLib.Theme.Text,
        ToggleBackground,
        8
    )

    local ToggleButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = ToggleFrame
    })

    -- Toggle API and state
    local ToggleAPI = {}
    local State = ToggleDefault
    
    function ToggleAPI:Set(NewState, force)
        -- Store previous state for comparison
        local PreviousState = State
        
        -- Set the new state
        State = NewState
        
        -- Only update visuals and trigger callback if the state actually changed or force is true
        if PreviousState ~= State or force then
            if State then
                Tween(ToggleBackground, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)
                Tween(ToggleIndicator, {Position = UDim2.new(0, 18, 0.5, -8)}, 0.2)
            else
                Tween(ToggleBackground, {BackgroundColor3 = TBDLib.Theme.Border}, 0.2)
                Tween(ToggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
            end
            
            -- Only trigger callback on actual changes, not initial setup
            if PreviousState ~= nil and (PreviousState ~= State or force) then
                ToggleCallback(State)
            end
            
            -- Update flag if specified
            if ToggleFlag then
                TBDLib.Flags[ToggleFlag] = {
                    Value = State,
                    Set = function(value) 
                        return ToggleAPI:Set(value, true) 
                    end
                }
            end
        end
        
        return State
    end

    function ToggleAPI:Get()
        return State
    end

    -- Initialize the toggle state
    ToggleAPI:Set(ToggleDefault)

    -- Connect toggle interaction with cross-platform compatibility
    -- Use InputBegan for better compatibility
    Connect(ToggleButton.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ToggleAPI:Set(not State)
        end
    end)

    -- Also try traditional MouseButton1Click for redundancy
    pcall(function()
        Connect(ToggleButton.MouseButton1Click, function()
            ToggleAPI:Set(not State)
        end)
    end)

    -- Register the flag if specified
    if ToggleFlag then
        TBDLib.Flags[ToggleFlag] = {
            Value = State,
            Set = ToggleAPI.Set
        }
    end

    return ToggleAPI
end

-- Add Slider
function SectionAPI:AddSlider(Config)
    Config = Config or {}
    local SliderText = Config.Text or "Slider"
    local SliderMin = Config.Min or 0
    local SliderMax = Config.Max or 100
    local SliderDefault = Config.Default or SliderMin
    local SliderIncrement = Config.Increment or 1
    local SliderCallback = Config.Callback or function() end
    local SliderFlag = Config.Flag

    -- Validate initial values
    SliderDefault = math.clamp(SliderDefault, SliderMin, SliderMax)
    SliderDefault = math.floor(SliderDefault / SliderIncrement + 0.5) * SliderIncrement

    local SliderFrame = Create("Frame", {
        Name = "Slider",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        SliderFrame.LayoutOrder = Config.Order
    end

    local SliderLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = SliderText,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = SliderFrame
    })

    local SliderValueLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -40, 0, 0),
        Size = UDim2.new(0, 40, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = tostring(SliderDefault),
        TextColor3 = TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = SliderFrame
    })

    local SliderContainer = CreateRoundedFrame(
        UDim2.new(1, 0, 0, 10),
        UDim2.new(0, 0, 0, 32),
        TBDLib.Theme.Border,
        SliderFrame,
        5
    )

    local SliderFill = CreateRoundedFrame(
        UDim2.new(0, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        TBDLib.Theme.Accent,
        SliderContainer,
        5
    )

    local SliderButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = SliderContainer
    })

    -- Slider API and state
    local SliderAPI = {}
    local Value = SliderDefault

    function SliderAPI:Set(NewValue, UpdateVisual)
        -- Validate and format the new value
        NewValue = math.clamp(NewValue, SliderMin, SliderMax)
        NewValue = math.floor(NewValue / SliderIncrement + 0.5) * SliderIncrement
        NewValue = tonumber(string.format("%.14g", NewValue))

        -- Update state
        Value = NewValue

        -- Update visuals if needed
        if UpdateVisual ~= false then
            local Percent = (Value - SliderMin) / (SliderMax - SliderMin)
            Tween(SliderFill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.2)
            SliderValueLabel.Text = tostring(Value)
        end

        -- Call callback
        SliderCallback(Value)

        -- Update flag if specified
        if SliderFlag then
            TBDLib.Flags[SliderFlag] = {
                Value = Value,
                Set = function(NewValue)
                    SliderAPI:Set(NewValue)
                end
            }
        end

        return Value
    end

    function SliderAPI:Get()
        return Value
    end

    -- Set initial value
    local InitialPercent = (SliderDefault - SliderMin) / (SliderMax - SliderMin)
    SliderFill.Size = UDim2.new(InitialPercent, 0, 1, 0)
    SliderValueLabel.Text = tostring(SliderDefault)

    -- Slider interaction
    local Dragging = false

    Connect(SliderButton.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true

            -- Update the slider value based on mouse position
            local Percent = math.clamp((Input.Position.X - SliderContainer.AbsolutePosition.X) / SliderContainer.AbsoluteSize.X, 0, 1)
            local NewValue = SliderMin + (SliderMax - SliderMin) * Percent
            SliderAPI:Set(NewValue)
        end
    end)

    Connect(UserInputService.InputEnded, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = false
        end
    end)

    Connect(UserInputService.InputChanged, function(Input)
        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            -- Update the slider value based on mouse position
            local Percent = math.clamp((Input.Position.X - SliderContainer.AbsolutePosition.X) / SliderContainer.AbsoluteSize.X, 0, 1)
            local NewValue = SliderMin + (SliderMax - SliderMin) * Percent
            SliderAPI:Set(NewValue)
        end
    end)

    -- Register the flag if specified
    if SliderFlag then
        TBDLib.Flags[SliderFlag] = {
            Value = Value,
            Set = function(NewValue)
                SliderAPI:Set(NewValue)
            end
        }
    end

    return SliderAPI
end

-- Add Dropdown
function SectionAPI:AddDropdown(Config)
    Config = Config or {}
    local DropdownText = Config.Text or "Dropdown"
    local DropdownItems = Config.Items or {}
    local DropdownCallback = Config.Callback or function() end
    local DropdownFlag = Config.Flag
    local DropdownDefault = Config.Default or (DropdownItems[1] or "")
    local DropdownMultiSelect = Config.MultiSelect or false

    local DropdownFrame = Create("Frame", {
        Name = "Dropdown",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        DropdownFrame.LayoutOrder = Config.Order
    end

    local DropdownLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = DropdownText,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = DropdownFrame
    })

    local DropdownContainer = CreateRoundedFrame(
        UDim2.new(1, 0, 0, 36),
        UDim2.new(0, 0, 0, 20),
        TBDLib.Theme.Tertiary,
        DropdownFrame,
        6
    )

    local DropdownSelected = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -46, 1, 0),
        Font = Enum.Font.Gotham,
        Text = DropdownDefault,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ClipsDescendants = true,
        Parent = DropdownContainer
    })

    local DropdownArrow = Create("ImageLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -32, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = TBDLib.Icons.Dropdown,
        ImageColor3 = TBDLib.Theme.TextDark,
        Parent = DropdownContainer
    })

    local DropdownButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        Parent = DropdownContainer
    })

    -- Create the dropdown menu (as child of main GUI to prevent layering issues)
    local MainGui = CoreGui:FindFirstChild("TBDLibContainer") 
    if not MainGui then
        -- Ensure the container exists before creating dropdown
        MainGui = Create("ScreenGui", {
            Name = "TBDLibContainer",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = CoreGui
        })
    end

    -- Ensure we have a proper container for dropdowns
    local DropdownLayer
    if not MainGui:FindFirstChild("DropdownLayer") then
        DropdownLayer = Create("Frame", {
            Name = "DropdownLayer",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 50000, -- Extremely high z-index to ensure it's always on top
            Parent = MainGui
        })
    else
        DropdownLayer = MainGui:FindFirstChild("DropdownLayer")
        -- Ensure existing layer has high z-index
        DropdownLayer.ZIndex = 50000
    end

    local DropdownMenu = CreateRoundedFrame(
        UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, 0),
        UDim2.new(0, 0, 0, 0),
        TBDLib.Theme.Tertiary,
        DropdownLayer,
        6,
        "DropdownMenu_" .. HttpService:GenerateGUID(false)
    )
    DropdownMenu.Visible = false
    DropdownMenu.ZIndex = 50001 -- Even higher z-index to ensure it's above the layer

    -- Don't use custom property to store reference, use a proper indexing approach instead
    -- Create a lookup table of container references for dropdown menus
    if not TBDLib.DropdownRefs then
        TBDLib.DropdownRefs = {}
    end
    local dropdownId = HttpService:GenerateGUID(false)
    TBDLib.DropdownRefs[dropdownId] = DropdownContainer
    DropdownMenu.Name = "DropdownMenu_" .. dropdownId

    local MenuList = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = DropdownMenu
    })

    local MenuPadding = Create("UIPadding", {
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = DropdownMenu
    })

    -- Dropdown state
    local DropdownAPI = {}
    local SelectedItems = {}

    if DropdownMultiSelect then
        if type(DropdownDefault) == "table" then
            for _, Item in ipairs(DropdownDefault) do
                SelectedItems[Item] = true
            end
        else
            SelectedItems[DropdownDefault] = true
        end
    else
        SelectedItems = DropdownDefault
    end

    -- Update the display text
    local function UpdateDisplayText()
        if DropdownMultiSelect then
            local Items = {}
            for Item, Selected in pairs(SelectedItems) do
                if Selected then
                    table.insert(Items, Item)
                end
            end

            if #Items == 0 then
                DropdownSelected.Text = "None"
            else
                DropdownSelected.Text = table.concat(Items, ", ")
            end
        else
            DropdownSelected.Text = SelectedItems or "None"
        end
    end

    -- Update the menu
    local function UpdateMenu()
        -- Clear existing items
        for _, Child in pairs(DropdownMenu:GetChildren()) do
            if Child:IsA("Frame") and Child.Name:find("Item_") then
                Child:Destroy()
            end
        end

        -- Create new items
        for i, Item in ipairs(DropdownItems) do
            local ItemButton = CreateRoundedFrame(
                UDim2.new(1, 0, 0, 30),
                nil,
                TBDLib.Theme.Secondary,
                DropdownMenu,
                4,
                "Item_" .. i
            )
            ItemButton.ZIndex = 11000

            local ItemText = Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -10, 1, 0),
                Font = Enum.Font.Gotham,
                Text = Item,
                TextColor3 = (DropdownMultiSelect and SelectedItems[Item]) or (not DropdownMultiSelect and SelectedItems == Item) 
                            and TBDLib.Theme.Accent or TBDLib.Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11001,
                Parent = ItemButton
            })

            local ItemButtonObj = Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 11002,
                Parent = ItemButton
            })

            -- Item click handler with touch support
            local function selectItem()
                if DropdownMultiSelect then
                    SelectedItems[Item] = not SelectedItems[Item]
                    ItemText.TextColor3 = SelectedItems[Item] and TBDLib.Theme.Accent or TBDLib.Theme.Text
                    UpdateDisplayText()
                    DropdownCallback(SelectedItems)
                else
                    SelectedItems = Item
                    UpdateDisplayText()
                    DropdownCallback(Item)

                    -- Hide menu if single select
                    Tween(DropdownMenu, {Size = UDim2.new(0, DropdownMenu.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
                        DropdownMenu.Visible = false
                    end)
                    Tween(DropdownArrow, {Rotation = 0}, 0.2)
                end

                -- Update flag value
                if DropdownFlag then
                    TBDLib.Flags[DropdownFlag] = {
                        Value = SelectedItems,
                        Set = function(NewValue)
                            SelectedItems = NewValue
                            UpdateDisplayText()
                            UpdateMenu()
                            DropdownCallback(SelectedItems)
                        end
                    }
                end
            end

            -- Button click with redundancy for cross-platform compatibility
            Connect(ItemButtonObj.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    selectItem()
                end
            end)

            -- Also try traditional click for platforms that support it
            pcall(function()
                Connect(ItemButtonObj.MouseButton1Click, selectItem)
            end)

            -- Hover effect
            Connect(ItemButtonObj.MouseEnter, function()
                Tween(ItemButton, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
            end)

            Connect(ItemButtonObj.MouseLeave, function()
                Tween(ItemButton, {BackgroundColor3 = TBDLib.Theme.Secondary}, 0.2)
            end)
        end

        -- Update size based on content
        local TotalHeight = MenuList.AbsoluteContentSize.Y + MenuPadding.PaddingTop.Offset + MenuPadding.PaddingBottom.Offset
        DropdownMenu.Size = UDim2.new(0, DropdownContainer.AbsoluteSize.X, 0, math.min(TotalHeight, 300))

        -- Enabling scrolling if needed
        if TotalHeight > 300 then
            local ScrollFrame = Create("ScrollingFrame", {
                Name = "ScrollFrame",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, TotalHeight),
                ScrollBarThickness = 4,
                ScrollingDirection = Enum.ScrollingDirection.Y,
                BorderSizePixel = 0,
                ZIndex = 11000,
                Parent = DropdownMenu
            })

            -- Move all children to the scroll frame
            for _, Child in pairs(DropdownMenu:GetChildren()) do
                if Child.Name ~= "ScrollFrame" and not Child:IsA("UIListLayout") and not Child:IsA("UIPadding") then
                    Child.Parent = ScrollFrame
                end
            end

            -- Move the layout to the scroll frame
            MenuList.Parent = ScrollFrame
            MenuPadding.Parent = ScrollFrame
        end
    end

    -- Show/hide menu function
    local function ToggleMenu()
        -- Position the menu under the dropdown
        local Position = DropdownContainer.AbsolutePosition
        local Size = DropdownContainer.AbsoluteSize
        local ScreenSize = workspace.CurrentCamera.ViewportSize

        -- Update menu for the correct items and current selection
        UpdateMenu()

        local MenuHeight = DropdownMenu.AbsoluteSize.Y
        local BelowSpace = ScreenSize.Y - (Position.Y + Size.Y)
        local AboveSpace = Position.Y

        -- Determine if menu should appear above or below
        local ShowAbove = BelowSpace < MenuHeight and AboveSpace > BelowSpace

        -- If previously visible, hide
        if DropdownMenu.Visible then
            Tween(DropdownMenu, {Size = UDim2.new(0, DropdownMenu.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
                DropdownMenu.Visible = false
            end)
            Tween(DropdownArrow, {Rotation = 0}, 0.2)
        else
            -- Show menu at correct position
            if ShowAbove then
                DropdownMenu.Position = UDim2.new(0, Position.X, 0, Position.Y - MenuHeight)
            else
                DropdownMenu.Position = UDim2.new(0, Position.X, 0, Position.Y + Size.Y)
            end

            DropdownMenu.Size = UDim2.new(0, Size.X, 0, 0)
            DropdownMenu.Visible = true

            -- Animate opening
            Tween(DropdownMenu, {Size = UDim2.new(0, Size.X, 0, DropdownMenu.AbsoluteSize.Y)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Tween(DropdownArrow, {Rotation = 180}, 0.2)

            -- Focus the menu to catch outside clicks
            DropdownLayer.BackgroundTransparency = 1
            DropdownLayer.Visible = true
            DropdownLayer.ZIndex = 10000
        end
    end

    -- Dropdown button click
    Connect(DropdownButton.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            ToggleMenu()
        end
    end)

    -- Also try traditional click
    pcall(function()
        Connect(DropdownButton.MouseButton1Click, ToggleMenu)
    end)

    -- Close on outside click
    Connect(DropdownLayer.InputBegan, function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and DropdownMenu.Visible then
            local Position = Input.Position
            local MenuPos = DropdownMenu.AbsolutePosition
            local MenuSize = DropdownMenu.AbsoluteSize

            -- Check if click was outside menu
            if Position.X < MenuPos.X or Position.X > MenuPos.X + MenuSize.X or
               Position.Y < MenuPos.Y or Position.Y > MenuPos.Y + MenuSize.Y then
                Tween(DropdownMenu, {Size = UDim2.new(0, DropdownMenu.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
                    DropdownMenu.Visible = false
                    DropdownLayer.Visible = false
                end)
                Tween(DropdownArrow, {Rotation = 0}, 0.2)
            end
        end
    end)

    -- Close menu on escape key
    Connect(UserInputService.InputBegan, function(Input)
        if Input.KeyCode == Enum.KeyCode.Escape and DropdownMenu.Visible then
            Tween(DropdownMenu, {Size = UDim2.new(0, DropdownMenu.AbsoluteSize.X, 0, 0)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
                DropdownMenu.Visible = false
                DropdownLayer.Visible = false
            end)
            Tween(DropdownArrow, {Rotation = 0}, 0.2)
        end
    end)

    -- Initial text update
    UpdateDisplayText()

    -- Dropdown API
    function DropdownAPI:SetItems(NewItems)
        DropdownItems = NewItems
        UpdateMenu()
    end

    function DropdownAPI:Clear()
        if DropdownMultiSelect then
            SelectedItems = {}
        else
            SelectedItems = ""
        end
        UpdateDisplayText()
        UpdateMenu()

        if DropdownFlag then
            TBDLib.Flags[DropdownFlag] = {
                Value = SelectedItems,
                Set = function(NewValue)
                    SelectedItems = NewValue
                    UpdateDisplayText()
                    UpdateMenu()
                    DropdownCallback(SelectedItems)
                end
            }
        end
    end

    function DropdownAPI:Set(Value)
        SelectedItems = Value
        UpdateDisplayText()
        UpdateMenu()
        DropdownCallback(Value)

        if DropdownFlag then
            TBDLib.Flags[DropdownFlag] = {
                Value = SelectedItems,
                Set = function(NewValue)
                    SelectedItems = NewValue
                    UpdateDisplayText()
                    UpdateMenu()
                    DropdownCallback(SelectedItems)
                end
            }
        end
    end

    function DropdownAPI:Get()
        return SelectedItems
    end

    -- Register the flag if specified
    if DropdownFlag then
        TBDLib.Flags[DropdownFlag] = {
            Value = SelectedItems,
            Set = function(NewValue)
                SelectedItems = NewValue
                UpdateDisplayText()
                UpdateMenu()
                DropdownCallback(SelectedItems)
            end
        }
    end

    return DropdownAPI
end

-- Add Textbox
function SectionAPI:AddTextbox(Config)
    Config = Config or {}
    local TextboxText = Config.Text or "Textbox"
    local TextboxPlaceholder = Config.Placeholder or "Type here..."
    local TextboxDefault = Config.Default or ""
    local TextboxCallback = Config.Callback or function() end
    local TextboxFlag = Config.Flag

    local TextboxFrame = Create("Frame", {
        Name = "Textbox",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        TextboxFrame.LayoutOrder = Config.Order
    end

    local TextboxLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 20),
        Font = Enum.Font.Gotham,
        Text = TextboxText,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TextboxFrame
    })

    local TextboxContainer = CreateRoundedFrame(
        UDim2.new(1, 0, 0, 36),
        UDim2.new(0, 0, 0, 20),
        TBDLib.Theme.Tertiary,
        TextboxFrame,
        6
    )

    local TextBox = Create("TextBox", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = TextboxDefault,
        PlaceholderText = TextboxPlaceholder,
        TextColor3 = TBDLib.Theme.Text,
        PlaceholderColor3 = TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = TextboxContainer
    })

    -- Focus border effect
    local TextboxBorder = CreateStroke(TextboxContainer, TBDLib.Theme.Accent, 1, 1)

    -- Focus/unfocus effects
    Connect(TextBox.Focused, function()
        Tween(TextboxBorder, {Transparency = 0}, 0.2)
    end)

    Connect(TextBox.FocusLost, function(EnterPressed)
        Tween(TextboxBorder, {Transparency = 1}, 0.2)
        TextboxCallback(TextBox.Text)

        -- Update flag if specified
        if TextboxFlag then
            TBDLib.Flags[TextboxFlag] = {
                Value = TextBox.Text,
                Set = function(NewValue)
                    TextBox.Text = NewValue
                    TextboxCallback(TextBox.Text)
                end
            }
        end
    end)

    -- Textbox API
    local TextboxAPI = {}

    function TextboxAPI:SetText(NewText)
        TextBox.Text = NewText
        TextboxCallback(TextBox.Text)

        -- Update flag if specified
        if TextboxFlag then
            TBDLib.Flags[TextboxFlag] = {
                Value = TextBox.Text,
                Set = function(NewValue)
                    TextBox.Text = NewValue
                    TextboxCallback(TextBox.Text)
                end
            }
        end
    end

    function TextboxAPI:GetText()
        return TextBox.Text
    end

    -- Register the flag if specified
    if TextboxFlag then
        TBDLib.Flags[TextboxFlag] = {
            Value = TextBox.Text,
            Set = function(NewValue)
                TextBox.Text = NewValue
                TextboxCallback(TextBox.Text)
            end
        }
    end

    return TextboxAPI
end

-- Add Keybind
function SectionAPI:AddKeybind(Config)
    Config = Config or {}
    local KeybindText = Config.Text or "Keybind"
    local KeybindDefault = Config.Default or Enum.KeyCode.Unknown
    local KeybindCallback = Config.Callback or function() end
    local KeybindFlag = Config.Flag

    local KeybindFrame = Create("Frame", {
        Name = "Keybind",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = SectionContent
    })

    -- Set element order if specified
    if Config.Order then
        KeybindFrame.LayoutOrder = Config.Order
    end

    local KeybindLabel = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        Font = Enum.Font.Gotham,
        Text = KeybindText,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = KeybindFrame
    })

    local KeybindContainer = CreateRoundedFrame(
        UDim2.new(0, 80, 0, 30),
        UDim2.new(1, -80, 0.5, -15),
        TBDLib.Theme.Tertiary,
        KeybindFrame,
        6
    )

    local KeybindButton = Create("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = KeybindDefault == Enum.KeyCode.Unknown and "None" or KeybindDefault.Name,
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 14,
        Parent = KeybindContainer
    })

    -- Keybind API and state
    local KeybindAPI = {}
    local SelectedKey = KeybindDefault
    local Listening = false

    function KeybindAPI:Set(Key)
        SelectedKey = Key
        KeybindButton.Text = Key == Enum.KeyCode.Unknown and "None" or Key.Name

        -- Update flag if specified
        if KeybindFlag then
            TBDLib.Flags[KeybindFlag] = {
                Value = SelectedKey,
                Set = KeybindAPI.Set
            }
        end
    end

    function KeybindAPI:Get()
        return SelectedKey
    end

    function KeybindAPI:StartListening()
        Listening = true
        KeybindButton.Text = "..."
        Tween(KeybindContainer, {BackgroundColor3 = TBDLib.Theme.Primary}, 0.2)
    end

    function KeybindAPI:StopListening()
        Listening = false
        KeybindButton.Text = SelectedKey == Enum.KeyCode.Unknown and "None" or SelectedKey.Name
        Tween(KeybindContainer, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
    end

    -- Connect button click to start listening with cross-platform compatibility
    Connect(KeybindButton.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if not Listening then
                KeybindAPI:StartListening()
            else
                KeybindAPI:StopListening()
            end
        end
    end)

    -- Connect input to detect key
    Connect(UserInputService.InputBegan, function(Input, GameProcessed)
        if not GameProcessed and Listening and Input.UserInputType == Enum.UserInputType.Keyboard then
            local Key = Input.KeyCode
            if Key == Enum.KeyCode.Escape then
                -- Clear keybind
                KeybindAPI:Set(Enum.KeyCode.Unknown)
            else
                KeybindAPI:Set(Key)
            end
            KeybindAPI:StopListening()
            KeybindCallback(SelectedKey)
        elseif not GameProcessed and not Listening and Input.KeyCode == SelectedKey then
            KeybindCallback(SelectedKey)
        end
    end)

    -- Register the flag if specified
    if KeybindFlag then
        TBDLib.Flags[KeybindFlag] = {
            Value = SelectedKey,
            Set = KeybindAPI.Set
        }
    end

    return KeybindAPI
end

-- Add Player Info component
function SectionAPI:AddPlayerInfo(PlayerInfo)
    PlayerInfo = PlayerInfo or {
        Player = {
            Name = "Player",
            DisplayName = "Player",
            AccountAge = 0,
            Avatar = TBDLib.Icons.Avatar
        },
        Game = {
            Name = "Game",
            PlaceId = 0
        }
    }

    -- Create player info frame
    local PlayerInfoFrame = Create("Frame", {
        Name = "PlayerInfo",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 100),
        Parent = SectionContent
    })

    -- Create avatar container
    local AvatarImageContainer = CreateRoundedFrame(
        UDim2.new(0, 80, 0, 80),
        UDim2.new(0, 10, 0.5, -40),
        Color3.fromRGB(40, 40, 40),
        PlayerInfoFrame,
        40,
        "AvatarContainer"
    )

    -- Add avatar image
    local AvatarImage = Create("ImageLabel", {
        Name = "Avatar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = PlayerInfo.Player.Avatar,
        Parent = AvatarImageContainer
    })

    -- Add rounded corners to avatar
    Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = AvatarImage
    })

    -- Create player name
    local PlayerName = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 10),
        Size = UDim2.new(1, -110, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = PlayerInfo.Player.DisplayName .. " (@" .. PlayerInfo.Player.Name .. ")",
        TextColor3 = TBDLib.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PlayerInfoFrame
    })

    -- Account age info
    local AccountAge = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 35),
        Size = UDim2.new(1, -110, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Account Age: " .. PlayerInfo.Player.AccountAge .. " days",
        TextColor3 = TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PlayerInfoFrame
    })

    -- Game info
    local GameInfo = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 55),
        Size = UDim2.new(1, -110, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Game: " .. PlayerInfo.Game.Name,
        TextColor3 = TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PlayerInfoFrame
    })

    -- Server info
    local ServerInfo = Create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 75),
        Size = UDim2.new(1, -110, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Server: " .. PlayerInfo.Server.Players .. "/" .. PlayerInfo.Server.MaxPlayers .. " players",
        TextColor3 = TBDLib.Theme.TextDark,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = PlayerInfoFrame
    })

    -- Create a simple API
    local PlayerInfoAPI = {}

    function PlayerInfoAPI:Update(NewPlayerInfo)
        PlayerInfo = NewPlayerInfo

        -- Update UI elements
        AvatarImage.Image = PlayerInfo.Player.Avatar
        PlayerName.Text = PlayerInfo.Player.DisplayName .. " (@" .. PlayerInfo.Player.Name .. ")"
        AccountAge.Text = "Account Age: " .. PlayerInfo.Player.AccountAge .. " days"
        GameInfo.Text = "Game: " .. PlayerInfo.Game.Name
        ServerInfo.Text = "Server: " .. PlayerInfo.Server.Players .. "/" .. PlayerInfo.Server.MaxPlayers .. " players"
    end

    return PlayerInfoAPI
end

return SectionAPI
end

return TabAPI
end

-- Select a tab by ID
function WindowAPI:SelectTab(TabId)
-- Add diagnostics for tab selection
if not Tabs then
warn("TBDLib: Tab container is nil in SelectTab")
return
end

if not Tabs[TabId] then
warn("TBDLib: Invalid tab ID in SelectTab: " .. tostring(TabId))
return
end

if ActiveTab == TabId then
-- Tab is already selected, just ensure it's visible
if Tabs[TabId].Content then
    Tabs[TabId].Content.Visible = true
end
return
end

-- Hide all tab contents with error handling
for _, Tab in pairs(Tabs) do
if Tab.Id ~= TabId then
    pcall(function()
        Tab.Content.Visible = false

        -- Reset button appearance
        Tween(Tab.Button, {BackgroundColor3 = TBDLib.Theme.Primary}, 0.2)

        local TitleLabel = Tab.Button:FindFirstChild("Title")
        if TitleLabel then
            Tween(TitleLabel, {TextColor3 = TBDLib.Theme.TextDark}, 0.2)
        end

        local IconLabel = Tab.Button:FindFirstChild("Icon")
        if IconLabel then
            Tween(IconLabel, {ImageColor3 = TBDLib.Theme.TextDark}, 0.2)
        end

        local Indicator = Tab.Button:FindFirstChild("Indicator")
        if Indicator then
            Tween(Indicator, {BackgroundTransparency = 1}, 0.2)
        end
    end)
end
end

-- Show selected tab content with error handling
pcall(function()
-- Ensure the tab content exists and is properly configured
if Tabs[TabId].Content then
    Tabs[TabId].Content.Visible = true
    Tabs[TabId].Content.ZIndex = 5 -- Ensure proper z-index

    -- Force update layouts for child elements
    for _, child in pairs(Tabs[TabId].Content:GetDescendants()) do
        if child:IsA("UIListLayout") or child:IsA("UIGridLayout") then
            child.Parent:GetPropertyChangedSignal("AbsoluteSize"):Wait()
        end
    end
else
    warn("TBDLib: Tab content is missing for TabId: " .. tostring(TabId))
end

-- Update button appearance
Tween(Tabs[TabId].Button, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)

local TitleLabel = Tabs[TabId].Button:FindFirstChild("Title")
if TitleLabel then
    Tween(TitleLabel, {TextColor3 = TBDLib.Theme.TextLight}, 0.2)
end

local IconLabel = Tabs[TabId].Button:FindFirstChild("Icon")
if IconLabel then
    Tween(IconLabel, {ImageColor3 = TBDLib.Theme.TextLight}, 0.2)
end

local Indicator = Tabs[TabId].Button:FindFirstChild("Indicator")
if Indicator then
    Tween(Indicator, {BackgroundTransparency = 0}, 0.2)
end
end)

-- Update active tab reference
ActiveTab = TabId
end

-- Select first tab by default if no default tab is specified
if Tabs and #Tabs > 0 then
-- Use pcall to handle any errors during initial tab selection
local success, err = pcall(function()
WindowAPI:SelectTab(1)
end)

if not success then
warn("TBDLib: Failed to select default tab - " .. tostring(err))
-- Try to set visibility directly as a fallback
if Tabs[1] and Tabs[1].Content then
    Tabs[1].Content.Visible = true
end
end
end

return WindowAPI
end

-- Configure the library
function TBDLib:Configure(Config)
Config = Config or {}
local NeedsThemeUpdate = false

-- Update theme
if Config.Theme then
NeedsThemeUpdate = true
for Key, Value in pairs(Config.Theme) do
self.Theme[Key] = Value
end
end

-- Update config folder
if Config.ConfigFolder then
self.ConfigSystem.Folder = Config.ConfigFolder
end

-- Update animation settings
if Config.Animation then
for Key, Value in pairs(Config.Animation) do
self.Animation[Key] = Value
end
end

-- Update notification settings
if Config.NotificationSettings then
for Key, Value in pairs(Config.NotificationSettings) do
self.NotificationSettings[Key] = Value
end
end

-- Apply theme to all UI elements if theme was updated
if NeedsThemeUpdate then
self:ApplyTheme()
end

return self
end

-- Apply the current theme to all UI elements
function TBDLib:ApplyTheme()
local Container = CoreGui:FindFirstChild("TBDLibContainer")
if not Container then return end

-- Function to update elements based on their type and properties
local function UpdateElement(Element)
-- Update background colors
if Element:IsA("Frame") or Element:IsA("ScrollingFrame") then
if Element.Name == "WindowFrame" then
    Element.BackgroundColor3 = self.Theme.Background
elseif Element.Name == "WindowContainer" or Element.Name:find("ContentFrame") then
    Element.BackgroundColor3 = self.Theme.Primary
elseif Element.Name:find("Sidebar") or Element.Name:find("TopBar") or Element.Name:find("Section") or 
       Element.Name:find("Content") then
    Element.BackgroundColor3 = self.Theme.Secondary
elseif Element.Name:find("Container") and not Element.Name:find("Window") then
    Element.BackgroundColor3 = self.Theme.Tertiary
elseif Element.Name:find("AccentBar") or Element.Name:find("ColorArea") or
       Element.Name:find("Indicator") and Element.BackgroundTransparency < 1 then
    Element.BackgroundColor3 = self.Theme.Accent
end
end

-- Update text colors
if Element:IsA("TextLabel") or Element:IsA("TextButton") or Element:IsA("TextBox") then
if Element.Name:find("Title") or Element.Name:find("Label") and not Element.Name:find("Placeholder") then
    Element.TextColor3 = self.Theme.Text
elseif Element.Name:find("Dark") or Element.Name:find("Description") then
    Element.TextColor3 = self.Theme.TextDark
end

if Element:IsA("TextBox") then
    Element.PlaceholderColor3 = self.Theme.TextDark
end
end

-- Update image colors for UI elements
if Element:IsA("ImageLabel") or Element:IsA("ImageButton") then
if Element.Name:find("Close") or Element.Name:find("Minimize") or Element.Name:find("Maximize") then
    Element.ImageColor3 = self.Theme.ControlBg
end
end

-- Recursively update children
for _, Child in ipairs(Element:GetChildren()) do
UpdateElement(Child)
end
end

-- Start the recursive update process
UpdateElement(Container)
end

-- Save and Load configurations
function TBDLib:SaveConfig(Name)
return SaveConfig(Name)
end

function TBDLib:LoadConfig(Name)
return LoadConfig(Name)
end

-- Cleanup function
function TBDLib:Destroy()
DisconnectAll()

if CoreGui:FindFirstChild("TBDLibContainer") then
CoreGui:FindFirstChild("TBDLibContainer"):Destroy()
end

for _, Connection in ipairs(Connections) do
Connection:Disconnect()
end

Connections = {}
TBDLib.Windows = {}
OpenFrames = {}
NotificationCount = 0
end

-- Return the library
return TBDLib
