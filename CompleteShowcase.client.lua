-- Ocean UI Lib by Fade - complete showcase
-- Copy this file into an executor/local test place to preview the public API.

local librarySource = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?complete_showcase=" .. os.clock())
local Library = assert(loadstring(librarySource), "Ocean UI Lib could not be loaded")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(77, 174, 255),
	WindowSize = Vector2.new(820, 680),
	WindowMinSize = Vector2.new(500, 440),
	WindowMaxSize = Vector2.new(1020, 840),
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local function notify(title, content, color)
	UI:Notify({
		Title = title,
		Content = content,
		Color = color or Color3.fromRGB(77, 174, 255),
		Icon = "✓",
		Duration = 3,
	})
end

-- 1. Layout, labels, buttons, and notifications.
local home = UI:Tab({Name = "Overview", Icon = "⌂", Description = "A polished introduction to the library."})
local homeSection = UI:Section({Tab = home, Name = "Welcome", Description = "Everything in this tab is built with the public API."})
homeSection:Label({Title = "Library status", Text = "ONLINE"})
homeSection:Label({Title = "Hosted release", Text = "GITHUB MAIN"})
homeSection:Label({Title = "Design system", Text = "FULLY CUSTOMIZABLE"})
homeSection:Button({Name = "Notification demo", Text = "TEST", Description = "Preview a polished animated notification.", Callback = function()
	notify("Ocean UI is ready", "Your interface can provide clear feedback with one callback.")
end})

-- 2. Every standard input control.
local controlsTab = UI:Tab({Name = "Controls", Icon = "◆", Description = "Toggle, slider, dropdown, input, color, and keybind examples."})
local controls = UI:Section({Tab = controlsTab, Name = "Control gallery", Description = "Each control supports callbacks and optional configuration flags."})
controls:Toggle({Name = "Feature toggle", Description = "A smooth on/off control.", Flag = "FeatureToggle", Default = true, Callback = function(value)
	notify("Feature toggle", value and "Enabled" or "Disabled")
end})
controls:Slider({Name = "Intensity slider", Description = "Select a numeric value with a smooth slider.", Flag = "Intensity", Min = 0, Max = 100, Default = 72, Format = "%d%%"})
controls:Dropdown({Name = "Mode dropdown", Description = "Bold, centered, font-safe option text.", Flag = "Mode", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 175})
controls:TextBox({Name = "Text box", Description = "Padded text input with focus styling.", Flag = "TextValue", Placeholder = "Type here...", Default = "Example", Width = 175})
controls:ColorPicker({Name = "Color picker", Description = "Circular palette, hue slider, hex, and RGB inputs.", Flag = "AccentColor", Default = Color3.fromRGB(77, 174, 255), Callback = function(color)
	UI:SetAccent(color)
end})
controls:Keybind({Name = "Toggle keybind", Description = "Bind a feature to any keyboard key.", Flag = "ToggleKey", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value)
	notify("Keybind changed", value and "Activated" or "Deactivated")
end})

-- 3. Runtime visual customization.
local visualsTab = UI:Tab({Name = "Appearance", Icon = "✦", Description = "Live themes, accents, logos, backgrounds, and sizing."})
local visuals = UI:Section({Tab = visualsTab, Name = "Visual customization", Description = "Update the interface at runtime without rebuilding the window."})
visuals:Dropdown({Name = "Accent preset", Options = {"Ocean", "Rose", "Mint", "Gold"}, Default = "Ocean", Width = 175, Callback = function(value)
	local colors = {
		Ocean = Color3.fromRGB(77, 174, 255),
		Rose = Color3.fromRGB(255, 105, 170),
		Mint = Color3.fromRGB(82, 220, 165),
		Gold = Color3.fromRGB(245, 190, 80),
	}
	UI:SetAccent(colors[value])
end})
visuals:Dropdown({Name = "Background mode", Options = {"Visible", "Hidden"}, Default = "Visible", Width = 175, Callback = function(value)
	UI:SetBackgroundVisible(value == "Visible")
end})
visuals:Button({Name = "Change logo", Text = "ICON", Width = 135, Callback = function()
	UI:SetLogo("rbxassetid://101595980825854")
	notify("Logo updated", "Branding can be changed at runtime.")
end})
visuals:Button({Name = "Resize window", Text = "RESIZE", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(900, 740))
end})
visuals:Button({Name = "Center window", Text = "CENTER", Width = 135, Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
end})

-- 4. Returned controls and configuration manager.
local utilityTab = UI:Tab({Name = "Utilities", Icon = "⚙", Description = "Programmatic methods, keybind panels, and saved configs."})
local utility = UI:Section({Tab = utilityTab, Name = "Production utilities", Description = "Useful pieces for a complete script product."})
local methodToggle = utility:Toggle({Name = "Programmatic toggle", Flag = "MethodToggle", Callback = function(value)
	print("Programmatic toggle:", value)
end})
utility:Button({Name = "Set toggle from code", Text = "SET", Width = 135, Callback = function()
	methodToggle.Set(true)
	notify("Control updated", "The returned control method changed the toggle.")
end})
utility:KeybindListToggle({Name = "Keybind panel", Default = false})
utility:HubToggleKeybind({Name = "Hub visibility key", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})

local configManager = UI:ConfigManager({Folder = "OceanUICompleteShowcase", DefaultConfig = "Default"})
local configName = utility:TextBox({Name = "Config name", Description = "Save and load control states.", Default = "Default", Placeholder = "Config name...", Width = 175})
utility:Button({Name = "Save configuration", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configManager:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
utility:Button({Name = "Load configuration", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configManager:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})

-- 5. Optional settings and clean-up.
local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Optional interface settings and clean reset actions."})
local settings = UI:Section({Tab = settingsTab, Name = "Interface options", Description = "Give users control over the experience."})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:Button({Name = "Reset layout", Text = "RESET", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(820, 680))
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
	UI:SetAccent(Color3.fromRGB(77, 174, 255))
	notify("Layout reset", "The showcase returned to its defaults.")
end})
settings:Button({Name = "Destroy interface", Text = "CLOSE", Width = 135, Callback = function()
	UI:Destroy()
end})

UI:Notify({Title = "Showcase ready", Content = "Explore every tab to preview Ocean UI Lib by Fade.", Icon = "✓", Duration = 5})
