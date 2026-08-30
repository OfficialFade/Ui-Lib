-- Ocean UI Lib by Fade - Buttons, Settings, and Stats HUD showcase

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?stats_showcase=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(820, 650),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local function notify(title, content, color)
	UI:Notify({Title = title, Content = content, Color = color or Color3.fromRGB(80, 175, 255), Icon = "✓", Duration = 3})
end

local buttonsTab = UI:Tab({Name = "Buttons", Icon = "◆", Description = "Showcase the available controls and callbacks."})
local buttons = UI:Section({Tab = buttonsTab, Name = "Component gallery", Description = "Buttons, toggles, sliders, dropdowns, inputs, pickers, and keybinds."})
buttons:Button({Name = "Button", Text = "CLICK", Description = "A polished callback button.", Callback = function() notify("Button clicked", "The callback ran successfully.") end})
buttons:Toggle({Name = "Toggle", Description = "A smooth on/off control.", Default = true, Callback = function(value) notify("Toggle", value and "Enabled" or "Disabled") end})
buttons:Slider({Name = "Slider", Description = "A formatted numeric slider.", Min = 0, Max = 100, Default = 70, Format = "%d%%"})
buttons:Dropdown({Name = "Dropdown", Description = "Bold, centered option text.", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 175})
buttons:TextBox({Name = "Text box", Description = "A clean, padded text input.", Placeholder = "Type here...", Default = "Example", Width = 175})
buttons:ColorPicker({Name = "Color picker", Description = "Circular palette with RGB and hex input.", Default = Color3.fromRGB(80, 175, 255), Callback = function(color) UI:SetAccent(color) end})
buttons:Keybind({Name = "Keybind", Description = "A configurable toggle key.", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value) notify("Keybind", value and "Activated" or "Deactivated") end})

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "OceanStatsHud"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local hud = Instance.new("Frame")
hud.Name = "StatsPanel"
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
hudHeader.Name = "DragHeader"
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
local hudClose = Instance.new("TextButton")
hudClose.Name = "Close"
hudClose.AnchorPoint = Vector2.new(1, 0.5)
hudClose.Position = UDim2.new(1, -8, 0, 15)
hudClose.Size = UDim2.fromOffset(22, 22)
hudClose.BackgroundColor3 = Color3.fromRGB(235, 92, 112)
hudClose.BackgroundTransparency = 0.08
hudClose.BorderSizePixel = 0
hudClose.AutoButtonColor = false
hudClose.Font = Enum.Font.GothamBold
hudClose.Text = "×"
hudClose.TextColor3 = Color3.fromRGB(255, 255, 255)
hudClose.TextSize = 14
hudClose.ZIndex = 3
hudClose.Parent = hud
local hudCloseCorner = Instance.new("UICorner")
hudCloseCorner.CornerRadius = UDim.new(0, 7)
hudCloseCorner.Parent = hudClose
hudClose.MouseEnter:Connect(function() hudClose.BackgroundColor3 = Color3.fromRGB(255, 120, 140) end)
hudClose.MouseLeave:Connect(function() hudClose.BackgroundColor3 = Color3.fromRGB(235, 92, 112) end)
local hudValues = Instance.new("TextLabel")
hudValues.BackgroundTransparency = 1
hudValues.Position = UDim2.fromOffset(12, 30)
hudValues.Size = UDim2.new(1, -24, 0, 56)
hudValues.Font = Enum.Font.GothamSemibold
hudValues.TextColor3 = Color3.fromRGB(170, 205, 235)
hudValues.TextSize = 11
hudValues.TextXAlignment = Enum.TextXAlignment.Left
hudValues.TextYAlignment = Enum.TextYAlignment.Top
hudValues.Text = "FPS: --\nPING: -- ms"
hudValues.Parent = hud
local dragging, dragStart, startPosition = false, nil, nil
hudHeader.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = hud.Position
	end
end)
hudHeader.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if not dragging or (input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch) then return end
	local delta = input.Position - dragStart
	hud.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
end)
hudClose.MouseButton1Click:Connect(function() hud.Visible = false end)
local frames, elapsed, fps = 0, 0, 0
local statsConnection = RunService.RenderStepped:Connect(function(delta)
	frames += 1
	elapsed += delta
	if elapsed >= 0.5 then
		fps = math.floor(frames / elapsed + 0.5)
		frames, elapsed = 0, 0
		local ping = "--"
		local ok, value = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString() end)
		if ok then ping = tostring(value):gsub(" ms", "") end
		hudValues.Text = string.format("FPS: %d\nPING: %s ms", fps, ping)
	end
end)

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Stats HUD, configs, visibility, and layout settings."})
local settings = UI:Section({Tab = settingsTab, Name = "Stats HUD", Description = "Toggle a lightweight FPS and ping overlay."})
settings:Toggle({Name = "Stats HUD", Description = "Show live FPS and ping in the corner.", Default = false, Callback = function(value)
	hud.Visible = value
	notify("Stats HUD", value and "Shown" or "Hidden")
end})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})

local configs = UI:ConfigManager({Folder = "OceanStatsShowcase", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Config name", Description = "Save and load control states.", Default = "Default", Placeholder = "Config name...", Width = 175})
settings:Button({Name = "Save configuration", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configs:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Load configuration", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configs:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Reset layout", Text = "RESET", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(820, 650))
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
	notify("Layout reset", "The default layout was restored.")
end})

UI:Notify({Title = "Showcase ready", Content = "Open Settings to enable the FPS and ping HUD.", Icon = "✓", Duration = 5})
