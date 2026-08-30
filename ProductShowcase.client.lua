-- Ocean UI Lib by Fade - complete product showcase
-- Generic examples for presenting the full public UI library.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?complete_product_showcase=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(820, 650),
	WindowMinSize = Vector2.new(500, 440),
	WindowMaxSize = Vector2.new(1000, 820),
	WindowPosition = UDim2.fromScale(0.5, 0.5),
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

local exampleTab = UI:Tab({Name = "Examples", Icon = "◆", Description = "Every control available in Ocean UI Lib."})
local examples = UI:Section({Tab = exampleTab, Name = "Control examples", Description = "Generic components ready to copy into any script."})
examples:Label({Title = "Example label", Text = "READY"})
examples:Button({Name = "Example button", Text = "TEST", Description = "A polished button with hover feedback and callbacks.", Callback = function()
	notify("Example button", "The button callback ran successfully.")
end})
examples:Toggle({Name = "Example toggle", Description = "A smooth on/off control.", Flag = "ExampleToggle", Default = true, Callback = function(value)
	print("Example toggle:", value)
end})
examples:Slider({Name = "Example slider", Description = "A responsive numeric slider with formatting.", Flag = "ExampleSlider", Min = 0, Max = 100, Default = 65, Format = "%d%%", Callback = function(value)
	print("Example slider:", value)
end})
examples:Dropdown({Name = "Example dropdown", Description = "Bold, centered, readable option text.", Flag = "ExampleDropdown", Options = {"First option", "Second option", "Third option"}, Default = "First option", Width = 175, Callback = function(value)
	print("Example dropdown:", value)
end})
examples:TextBox({Name = "Example text box", Description = "A clean padded input field.", Flag = "ExampleTextBox", Placeholder = "Type here...", Default = "Example text", Width = 175, Callback = function(value)
	print("Example text box:", value)
end})
examples:ColorPicker({Name = "Example color picker", Description = "Circular palette, hue slider, RGB, and hex input.", Flag = "ExampleColorPicker", Default = Color3.fromRGB(80, 175, 255), Callback = function(color)
	UI:SetAccent(color)
end})
examples:Keybind({Name = "Example keybind", Description = "Configurable toggle or hold input.", Flag = "ExampleKeybind", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value)
	notify("Example keybind", value and "Activated" or "Deactivated")
end})
examples:Button({Name = "Example notification", Text = "NOTIFY", Width = 135, Description = "Show animated notifications from any callback.", Callback = function()
	notify("Example notification", "This is the built-in notification component.")
end})

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Configuration and interface utility examples."})
local settings = UI:Section({Tab = settingsTab, Name = "Example configuration", Description = "Save, load, and manage user preferences."})
local configs = UI:ConfigManager({Folder = "OceanProductShowcase", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Example config name", Description = "Name the configuration file.", Default = "Default", Placeholder = "Config name...", Width = 175})
settings:Button({Name = "Example save config", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configs:Save(configName.Get())
	notify("Example save", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Example load config", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configs:Load(configName.Get())
	notify("Example load", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Example list configs", Text = "LIST", Width = 135, Callback = function()
	local names = configs:List()
	notify("Example configs", #names > 0 and table.concat(names, ", ") or "No configurations found.")
end})
settings:KeybindListToggle({Name = "Example keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Example hub key", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})

local utilities = UI:Section({Tab = settingsTab, Name = "Example interface options", Description = "Optional settings for a finished product."})
utilities:Toggle({Name = "Example search toggle", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
utilities:Toggle({Name = "Example profile toggle", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
utilities:Toggle({Name = "Example background toggle", Default = true, Callback = function(value) UI:SetBackgroundVisible(value) end})
utilities:Button({Name = "Example close button", Text = "CLOSE", Width = 135, Callback = function() UI:Destroy() end})

UI:Notify({Title = "Showcase ready", Content = "Explore Examples and Settings to view the full library.", Icon = "✓", Duration = 5})
