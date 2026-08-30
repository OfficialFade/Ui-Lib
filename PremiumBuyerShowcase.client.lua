-- Ocean UI Lib by Fade - premium buyer showcase
-- One complete example covering the public library API.

local raw = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?premium_showcase=" .. os.clock())
local Library = assert(loadstring(raw), "Could not load Ocean UI Lib")()
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
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false, -- Change to true to preview the optional loading transition.
})

local function notify(title, content, color)
	UI:Notify({Title = title, Content = content, Color = color or Color3.fromRGB(80, 175, 255), Icon = "✓", Duration = 3})
end

local overviewTab = UI:Tab({Name = "Overview", Icon = "⌂", Description = "A premium starting point for any Roblox script."})
local overview = UI:Section({Tab = overviewTab, Name = "Welcome", Description = "A fast tour of the Ocean UI Lib buyer experience."})
overview:Label({Title = "Library status", Text = "ONLINE"})
overview:Label({Title = "Release channel", Text = "GITHUB MAIN"})
overview:Label({Title = "Included systems", Text = "CONTROLS • THEMES • CONFIGS • HUD"})
overview:Button({Name = "Notification demo", Text = "TEST", Description = "Preview the animated notification system.", Callback = function()
	notify("Ocean UI is ready", "Clean feedback with a simple callback.")
end})

local controlsTab = UI:Tab({Name = "Controls", Icon = "◆", Description = "Every core component in one gallery."})
local controls = UI:Section({Tab = controlsTab, Name = "Component gallery", Description = "Showcase the complete control API."})
controls:Button({Name = "Button", Text = "CLICK", Description = "Gradient button with hover feedback.", Callback = function() notify("Button clicked", "Callback executed successfully.") end})
controls:Toggle({Name = "Toggle", Description = "Smooth on/off state.", Flag = "DemoToggle", Default = true, Callback = function(value) notify("Toggle", value and "Enabled" or "Disabled") end})
controls:Slider({Name = "Slider", Description = "Formatted numeric input.", Flag = "DemoSlider", Min = 0, Max = 100, Default = 70, Format = "%d%%"})
controls:Dropdown({Name = "Dropdown", Description = "Bold, centered, readable options.", Flag = "DemoDropdown", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 175})
controls:TextBox({Name = "Text box", Description = "Padded input with focus styling.", Flag = "DemoText", Placeholder = "Type here...", Default = "Example", Width = 175})
controls:ColorPicker({Name = "Color picker", Description = "Circular palette with hue, hex, and RGB controls.", Flag = "DemoColor", Default = Color3.fromRGB(80, 175, 255), Callback = function(color) UI:SetAccent(color) end})
controls:Keybind({Name = "Keybind", Description = "Toggle or hold actions with a configurable key.", Flag = "DemoKey", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value) notify("Keybind", value and "Activated" or "Deactivated") end})

local appearanceTab = UI:Tab({Name = "Appearance", Icon = "✦", Description = "Live branding and layout customization."})
local appearance = UI:Section({Tab = appearanceTab, Name = "Visual system", Description = "Change the interface at runtime without rebuilding it."})
appearance:Dropdown({Name = "Accent preset", Options = {"Ocean", "Rose", "Mint", "Gold"}, Default = "Ocean", Width = 175, Callback = function(value)
	local colors = {Ocean = Color3.fromRGB(80, 175, 255), Rose = Color3.fromRGB(255, 105, 170), Mint = Color3.fromRGB(82, 220, 165), Gold = Color3.fromRGB(245, 190, 80)}
	UI:SetAccent(colors[value])
end})
appearance:Dropdown({Name = "Background", Options = {"Visible", "Hidden"}, Default = "Visible", Width = 175, Callback = function(value) UI:SetBackgroundVisible(value == "Visible") end})
appearance:Button({Name = "Resize window", Text = "RESIZE", Width = 135, Callback = function() UI:SetWindowSize(Vector2.new(900, 740)) end})
appearance:Button({Name = "Center window", Text = "CENTER", Width = 135, Callback = function() UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5)) end})

-- Standalone draggable and closable FPS/ping HUD.
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "OceanPremiumStatsHud"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = Instance.new("Frame")
hud.Name = "StatsHud"
hud.Position = UDim2.fromOffset(18, 18)
hud.Size = UDim2.fromOffset(190, 104)
hud.BackgroundColor3 = Color3.fromRGB(13, 17, 28)
hud.BackgroundTransparency = 0.12
hud.BorderSizePixel = 0
hud.Visible = false
hud.Parent = hudGui
local hudCorner = Instance.new("UICorner")
hudCorner.CornerRadius = UDim.new(0, 10)
hudCorner.Parent = hud
local hudStroke = Instance.new("UIStroke")
hudStroke.Color = Color3.fromRGB(80, 175, 255)
hudStroke.Transparency = 0.25
hudStroke.Parent = hud
local hudGradient = Instance.new("UIGradient")
hudGradient.Color = ColorSequence.new(Color3.fromRGB(24, 34, 52), Color3.fromRGB(8, 12, 21))
hudGradient.Rotation = 135
hudGradient.Parent = hud
local hudHeader = Instance.new("Frame")
hudHeader.BackgroundTransparency = 1
hudHeader.Size = UDim2.new(1, -42, 0, 30)
hudHeader.Parent = hud
local hudTitle = Instance.new("TextLabel")
hudTitle.BackgroundTransparency = 1
hudTitle.Position = UDim2.fromOffset(12, 8)
hudTitle.Size = UDim2.new(1, -12, 0, 18)
hudTitle.Font = Enum.Font.GothamBold
hudTitle.Text = "LIVE STATS"
hudTitle.TextColor3 = Color3.fromRGB(235, 245, 255)
hudTitle.TextSize = 11
hudTitle.TextXAlignment = Enum.TextXAlignment.Left
hudTitle.Active = false
hudTitle.Parent = hudHeader
local closeHud = Instance.new("TextButton")
closeHud.AnchorPoint = Vector2.new(1, 0.5)
closeHud.Position = UDim2.new(1, -8, 0, 15)
closeHud.Size = UDim2.fromOffset(22, 22)
closeHud.BackgroundColor3 = Color3.fromRGB(235, 92, 112)
closeHud.BackgroundTransparency = 0.08
closeHud.BorderSizePixel = 0
closeHud.AutoButtonColor = false
closeHud.Font = Enum.Font.GothamBold
closeHud.Text = "×"
closeHud.TextColor3 = Color3.new(1, 1, 1)
closeHud.TextSize = 14
closeHud.Parent = hud
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeHud
local hudValues = Instance.new("TextLabel")
hudValues.BackgroundTransparency = 1
hudValues.Position = UDim2.fromOffset(12, 38)
hudValues.Size = UDim2.new(1, -24, 0, 52)
hudValues.Font = Enum.Font.GothamSemibold
hudValues.TextColor3 = Color3.fromRGB(170, 205, 235)
hudValues.TextSize = 11
hudValues.TextXAlignment = Enum.TextXAlignment.Left
hudValues.TextYAlignment = Enum.TextYAlignment.Top
hudValues.Text = "FPS: --\nPING: -- ms"
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
closeHud.MouseButton1Click:Connect(function() hud.Visible = false end)
local frames, elapsed = 0, 0
RunService.RenderStepped:Connect(function(delta)
	frames += 1
	elapsed += delta
	if elapsed >= 0.5 then
		local fps = math.floor(frames / elapsed + 0.5)
		frames, elapsed = 0, 0
		local ping = "--"
		local ok, value = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
		if ok then ping = tostring(value):gsub(" ms", "") end
		hudValues.Text = string.format("FPS: %d\nPING: %s ms", fps, ping)
	end
end)

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "HUD, configs, keybinds, and interface options."})
local settings = UI:Section({Tab = settingsTab, Name = "Stats HUD", Description = "Toggle the draggable and closable FPS/ping overlay."})
settings:Toggle({Name = "Stats HUD", Description = "Show live FPS and ping.", Default = false, Callback = function(value) hud.Visible = value end})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:Toggle({Name = "Background image", Default = true, Callback = function(value) UI:SetBackgroundVisible(value) end})
settings:KeybindListToggle({Name = "Keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})

local configs = UI:ConfigManager({Folder = "OceanPremiumShowcase", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Config name", Description = "Save and load all flagged controls.", Default = "Default", Placeholder = "Config name...", Width = 175})
settings:Button({Name = "Save config", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configs:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Load config", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configs:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Reset layout", Text = "RESET", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(840, 680))
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
	notify("Layout reset", "Default size and position restored.")
end})

UI:Notify({Title = "Premium showcase ready", Content = "Explore every tab to preview Ocean UI Lib by Fade.", Icon = "✓", Duration = 5})
