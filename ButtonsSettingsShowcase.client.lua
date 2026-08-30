-- Ocean UI Lib by Fade - focused buyer showcase
-- Exactly two tabs: Buttons (component gallery) and Settings (configuration mechanics).

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?buttons_showcase=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(820, 650),
	WindowMinSize = Vector2.new(500, 440),
	WindowMaxSize = Vector2.new(1000, 820),
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
		Color = color or Color3.fromRGB(80, 175, 255),
		Icon = "✓",
		Duration = 3,
	})
end

-- All showcased components live under this single tab.
local buttonsTab = UI:Tab({Name = "Buttons", Icon = "◆", Description = "Buttons, sliders, pickers, and input components."})
local buttons = UI:Section({Tab = buttonsTab, Name = "Component showcase", Description = "A compact gallery of the controls buyers can add to their own scripts."})
buttons:Label({Title = "Component status", Text = "READY FOR PRODUCTION"})
buttons:Button({Name = "Standard button", Text = "CLICK", Description = "A polished callback button with hover feedback.", Callback = function()
	notify("Button clicked", "Your callback was called successfully.")
end})
buttons:Toggle({Name = "Toggle button", Description = "Smooth on/off state with a callback.", Flag = "DemoToggle", Default = true, Callback = function(value)
	notify("Toggle changed", value and "Enabled" or "Disabled")
end})
buttons:Slider({Name = "Slider", Description = "Responsive numeric control with formatting.", Flag = "DemoSlider", Min = 0, Max = 100, Default = 70, Format = "%d%%"})
buttons:Dropdown({Name = "Dropdown", Description = "Bold, centered, readable option text.", Flag = "DemoDropdown", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 175})
buttons:TextBox({Name = "Text box", Description = "Clean padded input field with focus styling.", Flag = "DemoText", Placeholder = "Enter text...", Default = "Example", Width = 175})
buttons:ColorPicker({Name = "Color picker", Description = "Circular palette, hue slider, hex, and RGB fields.", Flag = "DemoColor", Default = Color3.fromRGB(80, 175, 255), Callback = function(color)
	UI:SetAccent(color)
end})
buttons:Keybind({Name = "Keybind", Description = "Toggle or hold actions with a configurable key.", Flag = "DemoKeybind", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value)
	notify("Keybind fired", value and "Activated" or "Deactivated")
end})
-- Configuration, visibility, and layout mechanics live under this tab.
local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Config saving, keybind utilities, and interface settings."})
local settings = UI:Section({Tab = settingsTab, Name = "Configuration manager", Description = "Save, load, and list user preferences with a small public API."})
local configManager = UI:ConfigManager({Folder = "OceanUIButtonsShowcase", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Config name", Description = "Choose a name for saved settings.", Placeholder = "Default", Default = "Default", Width = 175})
settings:Button({Name = "Save config", Text = "SAVE", Width = 135, Callback = function()
	local success, message = configManager:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "Load config", Text = "LOAD", Width = 135, Callback = function()
	local success, message = configManager:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(75, 205, 145) or Color3.fromRGB(235, 92, 112))
end})
settings:Button({Name = "List configs", Text = "LIST", Width = 135, Callback = function()
	local names = configManager:List()
	notify("Saved configurations", #names > 0 and table.concat(names, ", ") or "No configurations found.")
end})
settings:KeybindListToggle({Name = "Keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})

local interface = UI:Section({Tab = settingsTab, Name = "Interface options", Description = "Optional presentation settings for your product."})
interface:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
interface:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
interface:Toggle({Name = "Background image", Default = true, Callback = function(value) UI:SetBackgroundVisible(value) end})
interface:Button({Name = "Reset layout", Text = "RESET", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(820, 650))
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
	notify("Layout reset", "The showcase returned to its default position and size.")
end})
interface:Button({Name = "Close showcase", Text = "CLOSE", Width = 135, Callback = function()
	UI:Destroy()
end})

UI:Notify({Title = "Showcase ready", Content = "Buttons and Settings are ready to explore.", Icon = "✓", Duration = 5})
