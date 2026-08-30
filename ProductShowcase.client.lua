-- Ocean UI Lib by Fade - product showcase
-- A clean buyer demo with no resize controls: only features users can ship.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?product_showcase=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UIS = game:GetService("UserInputService")

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(840, 680),
	WindowMinSize = Vector2.new(500, 440),
	WindowMaxSize = Vector2.new(1020, 840),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false, -- Set true to showcase the optional loading transition.
})

local function notify(title, content, color)
	UI:Notify({Title = title, Content = content, Color = color or Color3.fromRGB(80, 175, 255), Icon = "✓", Duration = 3})
end

local homeTab = UI:Tab({Name = "Showcase", Icon = "⌂", Description = "A polished buyer-ready overview."})
local home = UI:Section({Tab = homeTab, Name = "Welcome", Description = "A flexible foundation for premium Roblox interfaces."})
home:Label({Title = "Library status", Text = "ONLINE"})
home:Label({Title = "Theme system", Text = "OCEAN GLASS"})
home:Label({Title = "Public API", Text = "READY TO SHIP"})
home:Button({Name = "Notification preview", Text = "TEST", Description = "Show the animated feedback system.", Callback = function()
	notify("Everything is connected", "Buttons, callbacks, and notifications are ready.")
end})

local controlsTab = UI:Tab({Name = "Components", Icon = "◆", Description = "The complete control collection."})
local controls = UI:Section({Tab = controlsTab, Name = "Control showcase", Description = "Use any combination of these components in your own product."})
controls:Button({Name = "Primary button", Text = "CLICK", Description = "Clean gradient styling with hover feedback.", Callback = function() notify("Primary action", "Button callback executed.") end})
controls:Button({Name = "Secondary button", Text = "PREVIEW", Width = 135, Description = "Multiple buttons can share one section.", Callback = function() notify("Preview", "A second action is ready.") end})
controls:Toggle({Name = "Toggle", Description = "Smooth, readable on/off state.", Flag = "ShowcaseToggle", Default = true, Callback = function(value) notify("Toggle", value and "Enabled" or "Disabled") end})
controls:Slider({Name = "Slider", Description = "Formatted numeric control.", Flag = "ShowcaseSlider", Min = 0, Max = 100, Default = 75, Format = "%d%%"})
controls:Dropdown({Name = "Dropdown", Description = "Bold and centered option text.", Flag = "ShowcaseDropdown", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 175})
controls:TextBox({Name = "Text box", Description = "Neat padded input with focus styling.", Flag = "ShowcaseText", Placeholder = "Type here...", Default = "Example", Width = 175})
controls:ColorPicker({Name = "Color picker", Description = "Palette, hue, hex, and RGB controls.", Flag = "ShowcaseColor", Default = Color3.fromRGB(80, 175, 255), Callback = function(color) UI:SetAccent(color) end})
controls:Keybind({Name = "Keybind", Description = "Toggle or hold actions with a configurable key.", Flag = "ShowcaseKey", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value) notify("Keybind", value and "Activated" or "Deactivated") end})

local appearanceTab = UI:Tab({Name = "Themes", Icon = "✦", Description = "Branding and appearance options."})
local appearance = UI:Section({Tab = appearanceTab, Name = "Theme showcase", Description = "Give every buyer a flexible visual system."})
appearance:Dropdown({Name = "Accent color", Options = {"Ocean", "Rose", "Mint", "Gold"}, Default = "Ocean", Width = 175, Callback = function(value)
	local colors = {Ocean = Color3.fromRGB(80, 175, 255), Rose = Color3.fromRGB(255, 105, 170), Mint = Color3.fromRGB(82, 220, 165), Gold = Color3.fromRGB(245, 190, 80)}
	UI:SetAccent(colors[value])
end})
appearance:Dropdown({Name = "Background style", Options = {"Ocean", "Glass only"}, Default = "Ocean", Width = 175, Callback = function(value)
	UI:SetBackgroundVisible(value == "Ocean")
end})
appearance:Button({Name = "Preview theme", Text = "PREVIEW", Width = 135, Callback = function()
	UI:SetAccent(Color3.fromRGB(80, 175, 255))
	UI:SetBackgroundVisible(true)
	notify("Ocean theme", "The default product theme is active.")
end})

-- Optional live FPS and ping HUD, matching the Ocean panel background.
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "OceanProductStats"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = Instance.new("Frame")
hud.Position = UDim2.fromOffset(18, 18)
hud.Size = UDim2.fromOffset(190, 104)
hud.BackgroundColor3 = Color3.fromRGB(13, 17, 28)
hud.BackgroundTransparency = 0.12
hud.BorderSizePixel = 0
hud.ClipsDescendants = true
hud.Visible = false
hud.Parent = hudGui
local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hud
local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(80, 175, 255)
hudStroke.Transparency = 0.25
hudStroke.Parent = hud
local hudBackdrop = Instance.new("ImageLabel")
hudBackdrop.Size = UDim2.fromScale(1, 1)
hudBackdrop.BackgroundTransparency = 1
hudBackdrop.Image = "rbxassetid://78664802433772"
hudBackdrop.ImageTransparency = 0.18
hudBackdrop.ScaleType = Enum.ScaleType.Crop
hudBackdrop.ZIndex = 0
hudBackdrop.Parent = hud
local hudGlass = Instance.new("Frame")
hudGlass.Size = UDim2.fromScale(1, 1)
hudGlass.BackgroundColor3 = Color3.fromRGB(7, 14, 25)
hudGlass.BackgroundTransparency = 0.28
hudGlass.BorderSizePixel = 0
hudGlass.ZIndex = 1
hudGlass.Parent = hud
local hudHeader = Instance.new("Frame")
hudHeader.Size = UDim2.new(1, -42, 0, 30)
hudHeader.BackgroundTransparency = 1
hudHeader.ZIndex = 2
hudHeader.Parent = hud
local hudTitle = Instance.new("TextLabel")
hudTitle.Position = UDim2.fromOffset(12, 8)
hudTitle.Size = UDim2.new(1, -12, 0, 18)
hudTitle.BackgroundTransparency = 1
hudTitle.Font = Enum.Font.GothamBold
hudTitle.Text = "LIVE STATS"
hudTitle.TextColor3 = Color3.fromRGB(235, 245, 255)
hudTitle.TextSize = 11
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.Active = false
hudTitle.ZIndex = 3
hudTitle.Parent = hudHeader
local hudClose = Instance.new("TextButton")
hudClose.AnchorPoint = Vector2.new(1, 0.5)
hudClose.Position = UDim2.new(1, -8, 0, 15)
hudClose.Size = UDim2.fromOffset(22, 22)
hudClose.BackgroundColor3 = Color3.fromRGB(235, 92, 112)
hudClose.BackgroundTransparency = 0.08
hudClose.BorderSizePixel = 0
hudClose.AutoButtonColor = false
hudClose.Font = Enum.Font.GothamBold
hudClose.Text = "×"
hudClose.TextColor3 = Color3.new(1, 1, 1)
hudClose.TextSize = 14
hudClose.ZIndex = 3
hudClose.Parent = hud
local hudCloseCorner = Instance.new("UICorner")
hudCloseCorner.CornerRadius = UDim.new(0, 7)
hudCloseCorner.Parent = hudClose
local hudValues = Instance.new("TextLabel")
hudValues.Position = UDim2.fromOffset(12, 38)
hudValues.Size = UDim2.new(1, -24, 0, 52)
hudValues.BackgroundTransparency = 1
hudValues.Font = Enum.Font.GothamSemibold
hudValues.Text = "FPS: --\nPING: -- ms"
hudValues.TextColor3 = Color3.fromRGB(170, 205, 235)
hudValues.TextSize = 11
hudValues.TextXAlignment = Enum.TextXAlignment.Left
hudValues.TextYAlignment = Enum.TextYAlignment.Top
hudValues.ZIndex = 3
hudValues.Parent = hud
local dragging, dragStart, hudStart = false, nil, nil
hudHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging, dragStart, hudStart = true, input.Position, hud.Position end
end)
hudHeader.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		hud.Position = UDim2.new(hudStart.X.Scale, hudStart.X.Offset + delta.X, hudStart.Y.Scale, hudStart.Y.Offset + delta.Y)
	end
end)
hudClose.MouseButton1Click:Connect(function() hud.Visible = false end)
local frameCount, timePassed = 0, 0
RunService.RenderStepped:Connect(function(delta)
	frameCount += 1
	timePassed += delta
	if timePassed >= 0.5 then
		local fps = math.floor(frameCount / timePassed + 0.5)
		frameCount, timePassed = 0, 0
		local ping = "--"
		local ok, value = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
		if ok then ping = tostring(value):gsub(" ms", "") end
		hudValues.Text = string.format("FPS: %d\nPING: %s ms", fps, ping)
	end
end)

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "HUD, configs, keybinds, and visibility."})
local settings = UI:Section({Tab = settingsTab, Name = "Product settings", Description = "Optional utilities buyers can enable or remove."})
settings:Toggle({Name = "Stats HUD", Description = "Show draggable FPS and ping information.", Default = false, Callback = function(value) hud.Visible = value end})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:Toggle({Name = "Ocean background", Default = true, Callback = function(value) UI:SetBackgroundVisible(value) end})
settings:KeybindListToggle({Name = "Keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})

local configs = UI:ConfigManager({Folder = "OceanProductShowcase", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Config name", Description = "Persist flagged control values.", Default = "Default", Placeholder = "Config name...", Width = 175})
settings:Button({Name = "Save configuration", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configs:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Load configuration", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configs:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "List configurations", Text = "LIST", Width = 135, Callback = function()
	local names = configs:List()
	notify("Saved configurations", #names > 0 and table.concat(names, ", ") or "No configurations found.")
end})

UI:Notify({Title = "Product showcase ready", Content = "Explore the tabs to preview everything Ocean UI Lib offers.", Icon = "✓", Duration = 5})
