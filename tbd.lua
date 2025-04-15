--[[
TBDLib - A Modern UI Library for Roblox

A sleek, feature-rich UI library designed specifically for script hubs and executors
with a wide layout design, smooth animations, and a modern aesthetic.

Version: 1.1.0
Author: TBD Development
License: MIT

GitHub: https://github.com/TBDDev/TBDLib
]]

-- Main Library Table
local TBDLib = {
Version = "1.1.0",
Windows = {},
ConfigSystem = {
Folder = "TBDLib",
CurrentConfig = "default"
},
Theme = {
-- Primary Colors
Primary = Color3.fromRGB(28, 33, 54),       -- Main Background
Secondary = Color3.fromRGB(35, 40, 60),     -- Secondary Background
Tertiary = Color3.fromRGB(42, 48, 70),      -- Container Background

-- Accent Colors
Accent = Color3.fromRGB(113, 93, 196),      -- Primary Accent
AccentDark = Color3.fromRGB(86, 70, 150),   -- Darker Accent
AccentLight = Color3.fromRGB(140, 120, 225),-- Lighter Accent

-- Status Colors
Success = Color3.fromRGB(72, 190, 118),     -- Success Color
Warning = Color3.fromRGB(240, 173, 78),     -- Warning Color
Error = Color3.fromRGB(231, 76, 101),       -- Error Color
Info = Color3.fromRGB(86, 180, 235),        -- Information Color

-- Text Colors
Text = Color3.fromRGB(240, 240, 250),       -- Primary Text
TextDark = Color3.fromRGB(190, 190, 200),   -- Secondary Text
TextLight = Color3.fromRGB(255, 255, 255),  -- Bright Text
TextDisabled = Color3.fromRGB(150, 150, 165),-- Disabled Text

-- UI Control Colors
ControlBg = Color3.fromRGB(255, 255, 255),  -- Control background (for better contrast)

-- Border and Other UI Elements
Border = Color3.fromRGB(50, 55, 75),        -- Border Color
Background = Color3.fromRGB(20, 22, 35),    -- Outermost Background
Divider = Color3.fromRGB(60, 65, 85),       -- Divider Lines

-- Notification Colors
NotifBackground = Color3.fromRGB(35, 40, 60),  -- Notification background
NotifText = Color3.fromRGB(240, 240, 250)      -- Notification text
},
Flags = {},
Icons = {
-- Basic UI Icons
Close = "rbxassetid://11482636247",
Minimize = "rbxassetid://11482636887",
Maximize = "rbxassetid://11482637164",
Settings = "rbxassetid://11482842244",
Search = "rbxassetid://11482842503",

-- Navigation Icons
Home = "rbxassetid://11482843511",
Scripts = "rbxassetid://11482919338",
Hub = "rbxassetid://11482947949",
Plugins = "rbxassetid://11482950479",
Games = "rbxassetid://11482966683",

-- Element Icons
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

local function Tween(Object, Properties, Duration, Style, Direction, Callback)
Duration = Duration or TBDLib.Animation.DefaultDuration
Style = Style or TBDLib.Animation.DefaultEasingStyle
Direction = Direction or TBDLib.Animation.DefaultEasingDirection

local TweenInfo = TweenInfo.new(Duration, Style, Direction)
local Tween = TweenService:Create(Object, TweenInfo, Properties)

if Callback then
Tween.Completed:Connect(Callback)
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
UIContainer.Enabled = UIVisible
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

Connect(CloseButton.MouseButton1Click, function()
CloseNotification(NotifFrame)
end)

-- Setup notification closing function (defined before usage)
local function CloseNotification(Frame)
if Frame and Frame:IsA("GuiObject") then
Tween(Frame, {
BackgroundTransparency = 1,
Position = UDim2.new(1, 0, 0, Frame.Position.Y.Offset)
}, 0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, function()
if Frame and Frame.Parent then
Frame:Destroy()
end
end)
end
end

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
if syn and syn.protect_gui then
syn.protect_gui(Container)
Container.Parent = CoreGui
elseif gethui then
Container.Parent = gethui()
else
Container.Parent = IsStudio and Player.PlayerGui or CoreGui
end

GUI = Container
else
GUI = CoreGui:FindFirstChild("TBDLibContainer")
end

-- Create window frame
local WindowFrame = CreateRoundedFrame(
UDim2.new(0, WindowConfig.Size.Width, 0, WindowConfig.Size.Height),
nil,
TBDLib.Theme.Background,
GUI,
10,
"WindowFrame"
)

-- Position the window
if WindowConfig.Center then
WindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
else
WindowFrame.Position = WindowConfig.Position or UDim2.new(0.5, -WindowConfig.Size.Width / 2, 0.5, -WindowConfig.Size.Height / 2)
end

-- Create a shadow
CreateShadow(WindowFrame, 0.4, 6)

-- Create window container (inside the frame)
local WindowContainer = CreateRoundedFrame(
UDim2.new(1, -20, 1, -20),
UDim2.new(0, 10, 0, 10),
TBDLib.Theme.Primary,
WindowFrame,
8,
"WindowContainer"
)

-- Create top bar
local TopBar = CreateRoundedFrame(
UDim2.new(1, 0, 0, 40),
UDim2.new(0, 0, 0, 0),
TBDLib.Theme.Secondary,
WindowContainer,
{8, 8, 0, 0},
"TopBar"
)

-- Add title to top bar
local TitleIcon
if WindowConfig.Icon then
TitleIcon = Create("ImageLabel", {
Name = "TitleIcon",
BackgroundTransparency = 1,
Position = UDim2.new(0, 15, 0, 8),
Size = UDim2.new(0, 24, 0, 24),
Image = WindowConfig.Icon,
Parent = TopBar
})
end

local TitleLabel = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.new(0, WindowConfig.Icon and 50 or 15, 0, 0),
Size = UDim2.new(1, WindowConfig.Icon and -120 or -90, 1, 0),
Font = Enum.Font.GothamBold,
Text = WindowConfig.Title,
TextColor3 = TBDLib.Theme.Text,
TextSize = 16,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = TopBar
})

-- Add window controls
local ControlsHolder = Create("Frame", {
Name = "Controls",
BackgroundTransparency = 1,
Position = UDim2.new(1, -105, 0, 0),
Size = UDim2.new(0, 105, 1, 0),
Parent = TopBar
})

-- Create circular background for buttons to make them more visible
local function CreateControlButton(Name, Icon, Position, Color)
local ButtonBackground = CreateRoundedFrame(
UDim2.new(0, 26, 0, 26),
Position,
Color or TBDLib.Theme.Tertiary,
ControlsHolder,
13,
Name .. "Background"
)

local Button = Create("ImageButton", {
Name = Name,
BackgroundTransparency = 1,
Position = UDim2.new(0.5, 0, 0.5, 0),
AnchorPoint = Vector2.new(0.5, 0.5),
Size = UDim2.new(0, 16, 0, 16),
Image = Icon,
ImageColor3 = TBDLib.Theme.Text,
Parent = ButtonBackground
})

return Button, ButtonBackground
end

local MinimizeButton, MinimizeBackground = CreateControlButton(
"Minimize", 
TBDLib.Icons.Minimize, 
UDim2.new(0, 10, 0.5, -13)
)

local MaximizeButton, MaximizeBackground = CreateControlButton(
"Maximize", 
TBDLib.Icons.Maximize, 
UDim2.new(0, 42, 0.5, -13)
)

local CloseButton, CloseBackground = CreateControlButton(
"Close", 
TBDLib.Icons.Close, 
UDim2.new(0, 74, 0.5, -13),
Color3.fromRGB(231, 76, 101)  -- Red background for close button
)

-- Button hover effects
Connect(MinimizeBackground.MouseEnter, function()
Tween(MinimizeBackground, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)
Tween(MinimizeButton, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
end)

Connect(MinimizeBackground.MouseLeave, function()
Tween(MinimizeBackground, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
Tween(MinimizeButton, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
end)

Connect(MaximizeBackground.MouseEnter, function()
Tween(MaximizeBackground, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)
Tween(MaximizeButton, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
end)

Connect(MaximizeBackground.MouseLeave, function()
Tween(MaximizeBackground, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
Tween(MaximizeButton, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
end)

Connect(CloseBackground.MouseEnter, function()
Tween(CloseBackground, {BackgroundColor3 = Color3.fromRGB(255, 90, 110)}, 0.2)
Tween(CloseButton, {ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
end)

Connect(CloseBackground.MouseLeave, function()
Tween(CloseBackground, {BackgroundColor3 = Color3.fromRGB(231, 76, 101)}, 0.2)
Tween(CloseButton, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
end)

-- Button click effects - Use InputBegan for reliable cross-platform support
-- Create a function to handle the close action to avoid code repetition
local function CloseWindowFunction()
    if WindowConfig.AutoSave then
        SaveConfig(WindowConfig.SaveConfig)
    end
    
    Tween(WindowFrame, {
        Size = UDim2.new(0, WindowFrame.Size.X.Offset, 0, 0),
        Position = UDim2.new(
            WindowFrame.Position.X.Scale,
            WindowFrame.Position.X.Offset,
            WindowFrame.Position.Y.Scale,
            WindowFrame.Position.Y.Offset + WindowFrame.Size.Y.Offset / 2
        )
    }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        DisconnectAll()
        GUI:Destroy()
    end)
end

-- Connect to button's InputBegan instead of MouseButton1Click for better mobile compatibility
Connect(CloseButton.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        CloseWindowFunction()
    end
end)

-- Connect to background's InputBegan for a larger click/touch area
Connect(CloseBackground.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        CloseWindowFunction()
    end
end)

-- For compatibility with platforms that properly support MouseButton1Click
pcall(function()
    Connect(CloseButton.MouseButton1Click, CloseWindowFunction)
    Connect(CloseBackground.MouseButton1Click, CloseWindowFunction)
end)

-- Optionally add Frame Activation method for even more redundancy
Tween(WindowFrame, {
        Size = UDim2.new(0, WindowFrame.Size.X.Offset, 0, 0),
        Position = UDim2.new(
            WindowFrame.Position.X.Scale,
            WindowFrame.Position.X.Offset,
            WindowFrame.Position.Y.Scale,
            WindowFrame.Position.Y.Offset + WindowFrame.Size.Y.Offset / 2
        )
    }, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
        DisconnectAll()
        GUI:Destroy()
    end)
end)

local Minimized = false

-- Add minimize button functionality
local function ToggleMinimize()
    -- Toggle minimize state
    Minimized = not Minimized
    
    -- Store window height if not minimized yet
    if not WindowFrame.OriginalHeight and not Minimized then
        WindowFrame.OriginalHeight = WindowFrame.Size.Y.Offset
    end
    
    if Minimized then
        -- Remember the original height before minimizing
        WindowFrame.OriginalHeight = WindowFrame.Size.Y.Offset
        
        -- Hide content except topbar when minimized
        Tween(WindowFrame, {
            Size = UDim2.new(0, WindowFrame.Size.X.Offset, 0, 50)
        }, 0.4)
        
        -- Change the minimize icon to a restore icon
        MinimizeButton.Image = TBDLib.Icons.Maximize
        
        -- Hide all UI elements except topbar with a visual effect
        for _, child in pairs(WindowContainer:GetChildren()) do
            if child ~= TopBar and child.Name ~= "Shadow" then
                if child:IsA("GuiObject") then
                    -- Animate transparency before hiding
                    Tween(child, {BackgroundTransparency = 1}, 0.3, nil, nil, function()
                        child.Visible = false
                    end)
                    
                    -- If the child has text labels, fade them out too
                    for _, descendant in pairs(child:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            Tween(descendant, {TextTransparency = 1}, 0.3)
                        elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
                            Tween(descendant, {ImageTransparency = 1}, 0.3)
                        end
                    end
                end
            end
        end
        
        -- Ensure the TopBar stays visible and opaque
        TopBar.Visible = true
        Tween(TopBar, {BackgroundTransparency = 0}, 0.3)
        
        -- Hide sidebar search separately
        if SidebarSearch then
            Tween(SidebarSearch, {BackgroundTransparency = 1}, 0.3, nil, nil, function()
                SidebarSearch.Visible = false
            end)
        end
    else
        -- Restore full window to its original height
        local targetHeight = WindowFrame.OriginalHeight or WindowConfig.Size.Height
        Tween(WindowFrame, {
            Size = UDim2.new(0, WindowFrame.Size.X.Offset, 0, targetHeight)
        }, 0.4)
        
        -- Restore the minimize icon
        MinimizeButton.Image = TBDLib.Icons.Minimize
        
        -- Show all UI elements with a slight delay to ensure animation completes
        task.delay(0.1, function()
            for _, child in pairs(WindowContainer:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = true
                    
                    -- Animate from transparent to visible
                    Tween(child, {BackgroundTransparency = child.BackgroundTransparency == 1 and 1 or 0}, 0.3)
                    
                    -- Restore opacity of children
                    for _, descendant in pairs(child:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            Tween(descendant, {TextTransparency = 0}, 0.3)
                        elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
                            Tween(descendant, {ImageTransparency = 0}, 0.3)
                        end
                    end
                end
            end
            
            -- Make search box visible again
            if SidebarSearch then
                SidebarSearch.Visible = true
                Tween(SidebarSearch, {BackgroundTransparency = 0}, 0.3)
            end
        end)
    end
end

-- Connect minimize button with cross-platform compatibility
-- First connect the button InputBegan (most reliable)
Connect(MinimizeButton.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        ToggleMinimize()
    end
end)

-- Then connect the background for touch and mouse input
Connect(MinimizeBackground.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        ToggleMinimize()
    end
end)

-- Use pcall for MouseButton1Click connections to avoid errors on platforms where it's not supported
pcall(function()
    Connect(MinimizeButton.MouseButton1Click, ToggleMinimize)
    Connect(MinimizeBackground.MouseButton1Click, ToggleMinimize)
end)

local Maximized = false

-- Add maximize button functionality
local function ToggleMaximize()
    -- This function is being repurposed as the split window function
    Maximized = not Maximized

    if Maximized then
        -- Store the current state
        local OldSize = {
            Width = WindowFrame.Size.X.Offset,
            Height = WindowFrame.Size.Y.Offset
        }
        WindowFrame.OldSize = OldSize
        WindowFrame.OldPosition = WindowFrame.Position

        -- Split into two windows by reducing the height of the current window
        Tween(WindowFrame, {
            Size = UDim2.new(0, OldSize.Width, 0, OldSize.Height / 2),
        }, 0.4)
        
        -- Create a second window that appears below the current one
        task.delay(0.1, function()
            -- Check if we need to create a new window or use the existing one
            local SecondWindowFrame = WindowFrame:FindFirstChild("SecondWindow")
            
            if not SecondWindowFrame then
                -- Create a new window with similar properties to the first one
                SecondWindowFrame = WindowFrame:Clone()
                SecondWindowFrame.Name = "SecondWindow"
                SecondWindowFrame.Size = UDim2.new(0, OldSize.Width, 0, OldSize.Height / 2)
                SecondWindowFrame.Position = UDim2.new(
                    WindowFrame.Position.X.Scale,
                    WindowFrame.Position.X.Offset,
                    WindowFrame.Position.Y.Scale,
                    WindowFrame.Position.Y.Offset + OldSize.Height / 2 + 5 -- Add a small gap
                )
                SecondWindowFrame.Parent = CoreGui:FindFirstChild("TBDLibContainer")
                
                -- Ensure the second window has a different title bar
                local TitleBar = SecondWindowFrame:FindFirstChild("WindowContainer"):FindFirstChild("TopBar")
                if TitleBar and TitleBar:FindFirstChild("Title") then
                    TitleBar.Title.Text = TitleBar.Title.Text .. " (Split)"
                end
            else
                -- Show the existing window
                SecondWindowFrame.Visible = true
                SecondWindowFrame.Position = UDim2.new(
                    WindowFrame.Position.X.Scale,
                    WindowFrame.Position.X.Offset,
                    WindowFrame.Position.Y.Scale,
                    WindowFrame.Position.Y.Offset + OldSize.Height / 2 + 5
                )
            end
        end)
    else
        -- Restore to original size and close/hide the second window
        if WindowFrame.OldSize then
            Tween(WindowFrame, {
                Size = UDim2.new(0, WindowFrame.OldSize.Width, 0, WindowFrame.OldSize.Height),
                Position = WindowFrame.OldPosition
            }, 0.4)
        end
        
        -- Find and hide the second window
        local SecondWindowFrame = WindowFrame:FindFirstChild("SecondWindow")
        if SecondWindowFrame then
            SecondWindowFrame.Visible = false
        end
    end
end

-- Connect maximize/split button with cross-platform compatibility
-- First connect the button InputBegan (most reliable)
Connect(MaximizeButton.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        ToggleMaximize()
    end
end)

-- Then connect the background for touch and mouse input
Connect(MaximizeBackground.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        ToggleMaximize()
    end
end)

-- Use pcall for MouseButton1Click connections to avoid errors on platforms where it's not supported
pcall(function()
    Connect(MaximizeButton.MouseButton1Click, ToggleMaximize)
    Connect(MaximizeBackground.MouseButton1Click, ToggleMaximize)
end)

-- Make window draggable from the top bar
MakeDraggable(WindowFrame, TopBar)

-- Create bottom drag handle for additional draggability
local BottomDragHandle = Create("Frame", {
    Name = "BottomDragHandle",
    BackgroundTransparency = 1, -- Invisible but functional
    Position = UDim2.new(0, 0, 1, -10),
    Size = UDim2.new(1, 0, 0, 10),
    Parent = WindowFrame
})

-- Make window draggable from the bottom as well
MakeDraggable(WindowFrame, BottomDragHandle)

-- Create content area (sidebar and main content)
local ContentFrame = CreateRoundedFrame(
UDim2.new(1, 0, 1, -50),
UDim2.new(0, 0, 0, 50),
TBDLib.Theme.Primary,
WindowContainer,
0,
"ContentFrame"
)

-- Create sidebar
local SidebarWidth = 220
local Sidebar = CreateRoundedFrame(
UDim2.new(0, SidebarWidth, 1, -10),
UDim2.new(0, 0, 0, 5),
TBDLib.Theme.Secondary,
ContentFrame,
8,
"Sidebar"
)

-- Add sidebar UI elements
local SidebarSearch = CreateRoundedFrame(
UDim2.new(1, -20, 0, 36),
UDim2.new(0, 10, 0, 10),
TBDLib.Theme.Tertiary,
Sidebar,
6,
"SidebarSearch"
)

local SearchIcon = Create("ImageLabel", {
Name = "SearchIcon",
BackgroundTransparency = 1,
Position = UDim2.new(0, 10, 0.5, -8),
Size = UDim2.new(0, 16, 0, 16),
Image = TBDLib.Icons.Search,
ImageColor3 = TBDLib.Theme.TextDark,
Parent = SidebarSearch
})

local SearchInput = Create("TextBox", {
Name = "SearchInput",
BackgroundTransparency = 1,
Position = UDim2.new(0, 36, 0, 0),
Size = UDim2.new(1, -46, 1, 0),
Font = Enum.Font.Gotham,
PlaceholderText = "Search...",
Text = "",
TextColor3 = TBDLib.Theme.Text,
PlaceholderColor3 = TBDLib.Theme.TextDark,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
ClearTextOnFocus = false,
Parent = SidebarSearch
})

-- Navigation Container
local NavContainer = Create("ScrollingFrame", {
Name = "NavContainer",
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 56),
Size = UDim2.new(1, 0, 1, -110),
CanvasSize = UDim2.new(0, 0, 0, 0),
ScrollBarThickness = 0,
ScrollingDirection = Enum.ScrollingDirection.Y,
AutomaticCanvasSize = Enum.AutomaticSize.Y,
Parent = Sidebar
})

local NavPadding = Create("UIPadding", {
PaddingLeft = UDim.new(0, 10),
PaddingRight = UDim.new(0, 10),
PaddingTop = UDim.new(0, 5),
PaddingBottom = UDim.new(0, 5),
Parent = NavContainer
})

local NavList = Create("UIListLayout", {
Padding = UDim.new(0, 8),
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = NavContainer
})

-- Utilities section at bottom of sidebar
local UtilitiesSection = CreateRoundedFrame(
UDim2.new(1, -20, 0, 0),
UDim2.new(0, 10, 1, -44),
TBDLib.Theme.Tertiary,
Sidebar,
8,
"UtilitiesSection"
)
UtilitiesSection.AutomaticSize = Enum.AutomaticSize.Y

local UtilitiesLayout = Create("UIListLayout", {
Padding = UDim.new(0, 5),
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder,
VerticalAlignment = Enum.VerticalAlignment.Center,
Parent = UtilitiesSection
})

local UtilitiesPadding = Create("UIPadding", {
PaddingTop = UDim.new(0, 8),
PaddingBottom = UDim.new(0, 8),
Parent = UtilitiesSection
})

-- Settings Button
local SettingsButton = Create("ImageButton", {
Name = "SettingsButton",
BackgroundTransparency = 1,
Size = UDim2.new(0, 24, 0, 24),
Image = TBDLib.Icons.Settings,
ImageColor3 = TBDLib.Theme.TextDark,
LayoutOrder = 1,
Parent = UtilitiesSection
})

Connect(SettingsButton.MouseEnter, function()
Tween(SettingsButton, {ImageColor3 = TBDLib.Theme.Text}, 0.2)
end)

Connect(SettingsButton.MouseLeave, function()
Tween(SettingsButton, {ImageColor3 = TBDLib.Theme.TextDark}, 0.2)
end)

-- Create tab container (main content area)
local TabContainer = CreateRoundedFrame(
UDim2.new(1, -SidebarWidth - 15, 1, -10),
UDim2.new(0, SidebarWidth + 10, 0, 5),
TBDLib.Theme.Secondary,
ContentFrame,
8,
"TabContainer"
)

-- Tab objects storage
local Tabs = {}
local ActiveTab = nil

-- Sidebar search functionality
Connect(SearchInput:GetPropertyChangedSignal("Text"), function()
local SearchText = string.lower(SearchInput.Text)

if SearchText == "" then
-- Show all tabs
for _, TabButton in pairs(NavContainer:GetChildren()) do
if TabButton:IsA("Frame") and TabButton.Name:find("NavButton_") then
TabButton.Visible = true
end
end
else
-- Filter tabs
for _, TabButton in pairs(NavContainer:GetChildren()) do
if TabButton:IsA("Frame") and TabButton.Name:find("NavButton_") then
local TabTitle = string.lower(TabButton.Title.Text)
TabButton.Visible = string.find(TabTitle, SearchText) ~= nil
end
end
end
end)

-- Window API
local WindowAPI = {}

function WindowAPI:AddTab(TabConfig)
TabConfig = TabConfig or {}
local TabId = #Tabs + 1
local TabName = TabConfig.Name or "Tab " .. TabId
local TabIcon = TabConfig.Icon

-- Create tab button in sidebar
local NavButton = CreateRoundedFrame(
UDim2.new(1, 0, 0, 40),
nil,
TBDLib.Theme.Primary,
NavContainer,
8,
"NavButton_" .. TabId
)

-- Order the tab
NavButton.LayoutOrder = TabConfig.Order or TabId

-- Create the icon if provided
local TabTitle
if TabIcon then
local Icon = Create("ImageLabel", {
Name = "Icon",
BackgroundTransparency = 1,
Position = UDim2.new(0, 10, 0.5, -10),
Size = UDim2.new(0, 20, 0, 20),
Image = TabIcon,
ImageColor3 = TBDLib.Theme.TextDark,
Parent = NavButton
})

TabTitle = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.new(0, 40, 0, 0),
Size = UDim2.new(1, -50, 1, 0),
Font = Enum.Font.GothamMedium,
Text = TabName,
TextColor3 = TBDLib.Theme.TextDark,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = NavButton
})
else
TabTitle = Create("TextLabel", {
Name = "Title",
BackgroundTransparency = 1,
Position = UDim2.new(0, 15, 0, 0),
Size = UDim2.new(1, -25, 1, 0),
Font = Enum.Font.GothamMedium,
Text = TabName,
TextColor3 = TBDLib.Theme.TextDark,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = NavButton
})
end

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

-- Button click effects
Connect(ButtonButton.MouseButton1Down, function()
Tween(Button, {BackgroundColor3 = Config.PressColor or TBDLib.Theme.AccentDark}, 0.1)
end)

Connect(ButtonButton.MouseButton1Up, function()
Tween(Button, {BackgroundColor3 = Config.HoverColor or TBDLib.Theme.AccentLight}, 0.1)
end)

-- Connect with InputBegan for consistent cross-platform behavior
Connect(ButtonButton.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        task.spawn(ButtonCallback)
    end
end)

-- Also try traditional MouseButton1Click for redundancy
pcall(function() 
    Connect(ButtonButton.MouseButton1Click, function()
        task.spawn(ButtonCallback)
    end)
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

function ToggleAPI:Set(NewState)
State = NewState

if State then
Tween(ToggleBackground, {BackgroundColor3 = TBDLib.Theme.Accent}, 0.2)
Tween(ToggleIndicator, {Position = UDim2.new(0, 18, 0.5, -8)}, 0.2)
else
Tween(ToggleBackground, {BackgroundColor3 = TBDLib.Theme.Border}, 0.2)
Tween(ToggleIndicator, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
end

ToggleCallback(State)

-- Update flag if specified
if ToggleFlag then
TBDLib.Flags[ToggleFlag] = {
    Value = State,
    Set = ToggleAPI.Set
}
end
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
        ZIndex = 10000,
        Parent = MainGui
    })
else
    DropdownLayer = MainGui:FindFirstChild("DropdownLayer")
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
DropdownMenu.ZIndex = 10001

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
ItemButton.ZIndex = 11

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
    ZIndex = 12,
    Parent = ItemButton
})

local ItemInteract = Create("TextButton", {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "",
    ZIndex = 12,
    Parent = ItemButton
})

-- Handle item selection
Connect(ItemInteract.MouseButton1Click, function()
    if DropdownMultiSelect then
        SelectedItems[Item] = not SelectedItems[Item]
        ItemText.TextColor3 = SelectedItems[Item] and TBDLib.Theme.Accent or TBDLib.Theme.Text
    else
        SelectedItems = Item
        DropdownAPI:Toggle() -- Close the menu for single select
    end

    UpdateDisplayText()
    DropdownCallback(DropdownMultiSelect and SelectedItems or Item)

    -- Update flag if specified
    if DropdownFlag then
        TBDLib.Flags[DropdownFlag] = {
            Value = SelectedItems,
            Set = DropdownAPI.SetValue
        }
    end
end)

-- Item hover effects
Connect(ItemInteract.MouseEnter, function()
    Tween(ItemButton, {BackgroundColor3 = TBDLib.Theme.Primary}, 0.2)
end)

Connect(ItemInteract.MouseLeave, function()
    Tween(ItemButton, {BackgroundColor3 = TBDLib.Theme.Secondary}, 0.2)
end)
end

-- Update the menu size
local ItemCount = math.min(8, #DropdownItems) -- Maximum 8 items visible at once
DropdownMenu.Size = UDim2.new(1, 0, 0, (ItemCount * 35) + 10)

-- Add a scrolling frame if there are many items
if #DropdownItems > 8 then
DropdownMenu.ClipsDescendants = true
else
DropdownMenu.ClipsDescendants = false
end
end

-- Toggle the dropdown menu
function DropdownAPI:Toggle()
    DropdownMenu.Visible = not DropdownMenu.Visible
    
    if DropdownMenu.Visible then
        -- Extract the dropdown ID from the menu name
        local dropdownId = string.match(DropdownMenu.Name, "DropdownMenu_(.+)")
        local container = TBDLib.DropdownRefs[dropdownId]
        
        if container then
            -- Update menu position to match dropdown container
            local AbsPos = container.AbsolutePosition
            local AbsSize = container.AbsoluteSize
            DropdownMenu.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + AbsSize.Y + 5)
            DropdownMenu.Size = UDim2.new(0, AbsSize.X, 0, 0)
            
            UpdateMenu()
            Tween(DropdownArrow, {Rotation = 180}, 0.2)
            
            -- Bring dropdown to front and ensure proper z-indexing
            DropdownMenu.ZIndex = 10000
            for _, child in ipairs(DropdownMenu:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.ZIndex = 10001
                    for _, subchild in ipairs(child:GetChildren()) do
                        if subchild:IsA("GuiObject") then
                            subchild.ZIndex = 10002
                        end
                    end
                end
            end
        else
            -- Log an error but don't crash
            print("Warning: Cannot find dropdown container reference for " .. DropdownMenu.Name)
        end
    else
        Tween(DropdownArrow, {Rotation = 0}, 0.2)
    end
end

-- Set dropdown value
function DropdownAPI:SetValue(Value)
if DropdownMultiSelect then
if type(Value) == "table" then
    SelectedItems = {}
    for _, Item in pairs(Value) do
        SelectedItems[Item] = true
    end
else
    SelectedItems = {[Value] = true}
end
else
SelectedItems = Value
end

UpdateDisplayText()
DropdownCallback(SelectedItems)

-- Update flag if specified
if DropdownFlag then
TBDLib.Flags[DropdownFlag] = {
    Value = SelectedItems,
    Set = DropdownAPI.SetValue
}
end
end

-- Get dropdown value
function DropdownAPI:GetValue()
if DropdownMultiSelect then
local Result = {}
for Item, Selected in pairs(SelectedItems) do
    if Selected then
        table.insert(Result, Item)
    end
end
return Result
else
return SelectedItems
end
end

-- Update dropdown items
function DropdownAPI:SetItems(Items)
DropdownItems = Items

-- Clear selection if needed
if DropdownMultiSelect then
SelectedItems = {}
else
SelectedItems = Items[1] or ""
end

UpdateDisplayText()

if DropdownMenu.Visible then
UpdateMenu()
end
end

-- Connect dropdown interactions with cross-platform compatibility
-- Use InputBegan for better compatibility
Connect(DropdownButton.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        DropdownAPI:Toggle()
    end
end)

-- Also try traditional MouseButton1Click for redundancy
pcall(function()
    Connect(DropdownButton.MouseButton1Click, function()
        DropdownAPI:Toggle()
    end)
end)

-- Close dropdown when clicking elsewhere
Connect(UserInputService.InputBegan, function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        local Position = UserInputService:GetMouseLocation()
        local MenuBounds = DropdownMenu.AbsolutePosition.Y + DropdownMenu.AbsoluteSize.Y
        
        -- Extract the dropdown ID from the menu name
        local dropdownId = string.match(DropdownMenu.Name, "DropdownMenu_(.+)")
        local container = TBDLib.DropdownRefs[dropdownId]
        
        if DropdownMenu.Visible and 
           (Position.Y < DropdownMenu.AbsolutePosition.Y or Position.Y > MenuBounds or
            Position.X < DropdownMenu.AbsolutePosition.X or Position.X > DropdownMenu.AbsolutePosition.X + DropdownMenu.AbsoluteSize.X) then
            
            if container then
                if not (Position.Y >= container.AbsolutePosition.Y and 
                       Position.Y <= container.AbsolutePosition.Y + container.AbsoluteSize.Y and
                       Position.X >= container.AbsolutePosition.X and 
                       Position.X <= container.AbsolutePosition.X + container.AbsoluteSize.X) then
                    DropdownAPI:Toggle()
                end
            else
                -- If container reference is gone, close the dropdown anyway
                DropdownAPI:Toggle()
            end
        end
    end
end)

-- Initialize dropdown state
UpdateDisplayText()

-- Register the flag if specified
if DropdownFlag then
TBDLib.Flags[DropdownFlag] = {
Value = SelectedItems,
Set = DropdownAPI.SetValue
}
end

return DropdownAPI
end

-- Add a text input
function SectionAPI:AddTextbox(Config)
Config = Config or {}
local TextboxText = Config.Text or "Textbox"
local TextboxPlaceholder = Config.Placeholder or "Enter text..."
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

local TextInput = Create("TextBox", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 12, 0, 0),
Size = UDim2.new(1, -24, 1, 0),
Font = Enum.Font.Gotham,
PlaceholderText = TextboxPlaceholder,
Text = TextboxDefault,
TextColor3 = TBDLib.Theme.Text,
PlaceholderColor3 = TBDLib.Theme.TextDark,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
ClearTextOnFocus = false,
Parent = TextboxContainer
})

-- Textbox API
local TextboxAPI = {}

function TextboxAPI:SetValue(Value)
TextInput.Text = Value or ""
TextboxCallback(TextInput.Text)

-- Update flag if specified
if TextboxFlag then
TBDLib.Flags[TextboxFlag] = {
    Value = TextInput.Text,
    Set = TextboxAPI.SetValue
}
end
end

function TextboxAPI:GetValue()
return TextInput.Text
end

-- Connect textbox events
Connect(TextInput.FocusLost, function(EnterPressed)
TextboxCallback(TextInput.Text)

-- Update flag if specified
if TextboxFlag then
TBDLib.Flags[TextboxFlag] = {
    Value = TextInput.Text,
    Set = TextboxAPI.SetValue
}
end
end)

-- Focus effect
Connect(TextInput.Focused, function()
Tween(TextboxContainer, {BackgroundColor3 = TBDLib.Theme.Primary}, 0.2)
end)

Connect(TextInput.FocusLost, function()
Tween(TextboxContainer, {BackgroundColor3 = TBDLib.Theme.Tertiary}, 0.2)
end)

-- Register the flag if specified
if TextboxFlag then
TBDLib.Flags[TextboxFlag] = {
Value = TextInput.Text,
Set = TextboxAPI.SetValue
}
end

return TextboxAPI
end

-- Add a Color Picker
function SectionAPI:AddColorPicker(Config)
Config = Config or {}
local ColorPickerText = Config.Text or "Color Picker"
local ColorPickerDefault = Config.Default or Color3.fromRGB(255, 255, 255)
local ColorPickerCallback = Config.Callback or function() end
local ColorPickerFlag = Config.Flag

local ColorPickerFrame = Create("Frame", {
Name = "ColorPicker",
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 0, 56),
Parent = SectionContent
})

-- Set element order if specified
if Config.Order then
ColorPickerFrame.LayoutOrder = Config.Order
end

local ColorPickerLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, -40, 0, 20),
Font = Enum.Font.Gotham,
Text = ColorPickerText,
TextColor3 = TBDLib.Theme.Text,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = ColorPickerFrame
})

local ColorDisplay = CreateRoundedFrame(
UDim2.new(0, 30, 0, 20),
UDim2.new(1, -36, 0, 0),
ColorPickerDefault,
ColorPickerFrame,
4
)

local ColorPickerContainer = CreateRoundedFrame(
UDim2.new(1, 0, 0, 36),
UDim2.new(0, 0, 0, 20),
TBDLib.Theme.Tertiary,
ColorPickerFrame,
6
)

local ColorPreview = CreateRoundedFrame(
UDim2.new(0, 30, 0, 20),
UDim2.new(0, 8, 0.5, -10),
ColorPickerDefault,
ColorPickerContainer,
4
)

local ColorLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 46, 0, 0),
Size = UDim2.new(1, -90, 1, 0),
Font = Enum.Font.Gotham,
Text = string.format("%d, %d, %d", 
math.floor(ColorPickerDefault.R * 255 + 0.5),
math.floor(ColorPickerDefault.G * 255 + 0.5),
math.floor(ColorPickerDefault.B * 255 + 0.5)
),
TextColor3 = TBDLib.Theme.Text,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = ColorPickerContainer
})

local ColorPickerButton = Create("TextButton", {
BackgroundTransparency = 1,
Size = UDim2.new(1, 0, 1, 0),
Text = "",
Parent = ColorPickerContainer
})

-- Create color picker popup
local ColorPopup = CreateRoundedFrame(
UDim2.new(0, 240, 0, 260),
UDim2.new(0, 0, 0, ColorPickerContainer.AbsoluteSize.Y + 5),
TBDLib.Theme.Secondary,
ColorPickerFrame,
8,
"ColorPopup"
)
ColorPopup.Visible = false
ColorPopup.ZIndex = 100

-- Add shadow to popup
CreateShadow(ColorPopup, 0.5)

-- Create color picker elements
local ColorArea = CreateRoundedFrame(
UDim2.new(1, -20, 0, 160),
UDim2.new(0, 10, 0, 10),
Color3.fromRGB(255, 0, 0),
ColorPopup,
6,
"ColorArea"
)
ColorArea.ZIndex = 101

-- Create white to black gradient
local WhiteGradient = Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255, 0))
}),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 0),
NumberSequenceKeypoint.new(1, 0)
}),
Rotation = 0,
Parent = ColorArea
})

-- Create transparent to black gradient
local BlackGradient = Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0, 0)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
}),
Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(1, 0)
}),
Rotation = 90,
Parent = ColorArea
})

-- Create color selector
local ColorSelector = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
Size = UDim2.new(0, 12, 0, 12),
Position = UDim2.new(1, 0, 0, 0),
ZIndex = 103,
Parent = ColorArea
})

local SelectorUICorner = Create("UICorner", {
CornerRadius = UDim.new(1, 0),
Parent = ColorSelector
})

local SelectorUIStroke = Create("UIStroke", {
Color = Color3.fromRGB(0, 0, 0),
Thickness = 1,
Parent = ColorSelector
})

-- Create hue slider
local HueSlider = CreateRoundedFrame(
UDim2.new(1, -20, 0, 20),
UDim2.new(0, 10, 0, 180),
Color3.fromRGB(255, 255, 255),
ColorPopup,
6,
"HueSlider"
)
HueSlider.ZIndex = 101

-- Add hue gradient
local HueGradient = Create("UIGradient", {
Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
}),
Rotation = 0,
Parent = HueSlider
})

-- Create hue selector
local HueSelector = Create("Frame", {
AnchorPoint = Vector2.new(0.5, 0.5),
BackgroundColor3 = Color3.fromRGB(255, 255, 255),
Size = UDim2.new(0, 6, 1, 6),
Position = UDim2.new(0, 0, 0, 0),
ZIndex = 103,
Parent = HueSlider
})

local HueSelectorUICorner = Create("UICorner", {
CornerRadius = UDim.new(1, 0),
Parent = HueSelector
})

local HueSelectorUIStroke = Create("UIStroke", {
Color = Color3.fromRGB(0, 0, 0),
Thickness = 1,
Parent = HueSelector
})

-- RGB inputs
local RGBContainer = Create("Frame", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 10, 0, 210),
Size = UDim2.new(1, -20, 0, 40),
ZIndex = 101,
Parent = ColorPopup
})

local RGBLayout = Create("UIListLayout", {
Padding = UDim.new(0, 10),
FillDirection = Enum.FillDirection.Horizontal,
HorizontalAlignment = Enum.HorizontalAlignment.Center,
SortOrder = Enum.SortOrder.LayoutOrder,
Parent = RGBContainer
})

-- Create R, G, B inputs
local Inputs = {}

for i, Color in ipairs({"R", "G", "B"}) do
local InputContainer = CreateRoundedFrame(
UDim2.new(0, 60, 0, 40),
nil,
TBDLib.Theme.Tertiary,
RGBContainer,
6,
Color .. "Container"
)
InputContainer.ZIndex = 102
InputContainer.LayoutOrder = i

local InputLabel = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 0),
Size = UDim2.new(1, 0, 0, 18),
Font = Enum.Font.GothamBold,
Text = Color,
TextColor3 = TBDLib.Theme.Text,
TextSize = 12,
ZIndex = 103,
Parent = InputContainer
})

local InputBox = Create("TextBox", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 0, 0, 18),
Size = UDim2.new(1, 0, 0, 22),
Font = Enum.Font.Gotham,
Text = "255",
TextColor3 = TBDLib.Theme.Text,
TextSize = 14,
ZIndex = 103,
Parent = InputContainer
})

Inputs[Color] = InputBox
end

-- ColorPicker API and state
local ColorPickerAPI = {}
local SelectedColor = ColorPickerDefault
local Hue, Saturation, Value = 0, 0, 1

-- Convert RGB to HSV
local function RGBtoHSV(Color)
local R, G, B = Color.R, Color.G, Color.B
local Max, Min = math.max(R, G, B), math.min(R, G, B)
local H, S, V

V = Max

local Delta = Max - Min
if Max > 0 then
S = Delta / Max
else
S = 0
H = 0
return H, S, V
end

if R == Max then
H = (G - B) / Delta
elseif G == Max then
H = 2 + (B - R) / Delta
else
H = 4 + (R - G) / Delta
end

H = H * 60
if H < 0 then
H = H + 360
end

return H / 360, S, V
end

-- Convert HSV to RGB
local function HSVtoRGB(H, S, V)
local R, G, B

if S == 0 then
R, G, B = V, V, V
else
H = H * 6
local I = math.floor(H)
local F = H - I
local P = V * (1 - S)
local Q = V * (1 - S * F)
local T = V * (1 - S * (1 - F))

if I == 0 or I == 6 then
    R, G, B = V, T, P
elseif I == 1 then
    R, G, B = Q, V, P
elseif I == 2 then
    R, G, B = P, V, T
elseif I == 3 then
    R, G, B = P, Q, V
elseif I == 4 then
    R, G, B = T, P, V
elseif I == 5 then
    R, G, B = V, P, Q
end
end

return Color3.fromRGB(R * 255, G * 255, B * 255)
end

-- Update color from HSV
local function UpdateColor()
SelectedColor = HSVtoRGB(Hue, Saturation, Value)

-- Update color area background
ColorArea.BackgroundColor3 = HSVtoRGB(Hue, 1, 1)

-- Update color selector position
ColorSelector.Position = UDim2.new(Saturation, 0, 1 - Value, 0)

-- Update hue selector position
HueSelector.Position = UDim2.new(Hue, 0, 0.5, 0)

-- Update RGB inputs
Inputs.R.Text = tostring(math.floor(SelectedColor.R * 255 + 0.5))
Inputs.G.Text = tostring(math.floor(SelectedColor.G * 255 + 0.5))
Inputs.B.Text = tostring(math.floor(SelectedColor.B * 255 + 0.5))

-- Update RGB display text
ColorLabel.Text = string.format("%d, %d, %d", 
math.floor(SelectedColor.R * 255 + 0.5),
math.floor(SelectedColor.G * 255 + 0.5),
math.floor(SelectedColor.B * 255 + 0.5)
)

-- Update color previews
ColorPreview.BackgroundColor3 = SelectedColor
ColorDisplay.BackgroundColor3 = SelectedColor

-- Call callback
ColorPickerCallback(SelectedColor)

-- Update flag if specified
if ColorPickerFlag then
TBDLib.Flags[ColorPickerFlag] = {
    Value = SelectedColor,
    Set = ColorPickerAPI.SetColor
}
end
end

-- Set color value
function ColorPickerAPI:SetColor(Color)
SelectedColor = Color
Hue, Saturation, Value = RGBtoHSV(Color)
UpdateColor()
end

function ColorPickerAPI:GetColor()
return SelectedColor
end

-- Toggle the color picker popup
function ColorPickerAPI:Toggle()
ColorPopup.Visible = not ColorPopup.Visible

if ColorPopup.Visible then
-- Reset values to current color
Hue, Saturation, Value = RGBtoHSV(SelectedColor)
UpdateColor()
end
end

-- Initialize color picker
Hue, Saturation, Value = RGBtoHSV(ColorPickerDefault)
UpdateColor()

-- Color picker area interaction
local ColorAreaDragging = false

Connect(ColorArea.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
ColorAreaDragging = true

-- Update saturation and value based on mouse position
local Position = Vector2.new(
    math.clamp((Input.Position.X - ColorArea.AbsolutePosition.X) / ColorArea.AbsoluteSize.X, 0, 1),
    math.clamp((Input.Position.Y - ColorArea.AbsolutePosition.Y) / ColorArea.AbsoluteSize.Y, 0, 1)
)

Saturation = Position.X
Value = 1 - Position.Y

UpdateColor()
end
end)

Connect(UserInputService.InputEnded, function(Input)
if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
ColorAreaDragging = false
end
end)

Connect(UserInputService.InputChanged, function(Input)
if ColorAreaDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
-- Update saturation and value based on mouse position
local Position = Vector2.new(
    math.clamp((Input.Position.X - ColorArea.AbsolutePosition.X) / ColorArea.AbsoluteSize.X, 0, 1),
    math.clamp((Input.Position.Y - ColorArea.AbsolutePosition.Y) / ColorArea.AbsoluteSize.Y, 0, 1)
)

Saturation = Position.X
Value = 1 - Position.Y

UpdateColor()
end
end)

-- Hue slider interaction
local HueDragging = false

Connect(HueSlider.InputBegan, function(Input)
if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
HueDragging = true

-- Update hue based on mouse position
local Position = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
Hue = Position

UpdateColor()
end
end)

Connect(UserInputService.InputEnded, function(Input)
if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
HueDragging = false
end
end)

Connect(UserInputService.InputChanged, function(Input)
if HueDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
-- Update hue based on mouse position
local Position = math.clamp((Input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
Hue = Position

UpdateColor()
end
end)

-- RGB input handlers
for Color, Input in pairs(Inputs) do
Connect(Input.FocusLost, function()
local Number = tonumber(Input.Text)
if Number then
    Number = math.clamp(math.floor(Number), 0, 255)
    Input.Text = tostring(Number)

    local R = tonumber(Inputs.R.Text) / 255
    local G = tonumber(Inputs.G.Text) / 255
    local B = tonumber(Inputs.B.Text) / 255

    SelectedColor = Color3.fromRGB(R * 255, G * 255, B * 255)
    Hue, Saturation, Value = RGBtoHSV(SelectedColor)

    UpdateColor()
else
    Input.Text = tostring(math.floor(SelectedColor[Color:lower()] * 255 + 0.5))
end
end)
end

-- Connect color picker button to toggle popup
Connect(ColorPickerButton.MouseButton1Click, function()
ColorPickerAPI:Toggle()
end)

-- Close popup when clicking elsewhere
Connect(UserInputService.InputBegan, function(Input)
if ColorPopup.Visible and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
local Position = UserInputService:GetMouseLocation()

if Position.Y < ColorPopup.AbsolutePosition.Y or 
   Position.Y > ColorPopup.AbsolutePosition.Y + ColorPopup.AbsoluteSize.Y or
   Position.X < ColorPopup.AbsolutePosition.X or 
   Position.X > ColorPopup.AbsolutePosition.X + ColorPopup.AbsoluteSize.X then

    if not (Position.Y >= ColorPickerContainer.AbsolutePosition.Y and 
           Position.Y <= ColorPickerContainer.AbsolutePosition.Y + ColorPickerContainer.AbsoluteSize.Y and
           Position.X >= ColorPickerContainer.AbsolutePosition.X and 
           Position.X <= ColorPickerContainer.AbsolutePosition.X + ColorPickerContainer.AbsoluteSize.X) then
        ColorPickerAPI:Toggle()
    end
end
end
end)

-- Register the flag if specified
if ColorPickerFlag then
TBDLib.Flags[ColorPickerFlag] = {
Value = SelectedColor,
Set = ColorPickerAPI.SetColor
}
end

return ColorPickerAPI
end

-- Add a keybind
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
Size = UDim2.new(1, -90, 1, 0),
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

-- Connect button click to start listening
Connect(KeybindButton.MouseButton1Click, function()
if not Listening then
KeybindAPI:StartListening()
else
KeybindAPI:StopListening()
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

-- Place ID info
local PlaceID = Create("TextLabel", {
BackgroundTransparency = 1,
Position = UDim2.new(0, 100, 0, 75),
Size = UDim2.new(1, -110, 0, 20),
Font = Enum.Font.Gotham,
Text = "Place ID: " .. PlayerInfo.Game.PlaceId,
TextColor3 = TBDLib.Theme.TextDark,
TextSize = 14,
TextXAlignment = Enum.TextXAlignment.Left,
Parent = PlayerInfoFrame
})

-- Set layout order if needed
PlayerInfoFrame.LayoutOrder = 0

return PlayerInfoFrame
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
