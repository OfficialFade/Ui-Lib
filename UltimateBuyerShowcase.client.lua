-- Clapped Hub UI Lib - ultimate buyer showcase
-- Loads the published library and demonstrates the complete public API.

-- Pin this to a commit so buyers never receive a stale CDN copy.
local LIBRARY_URL = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/e692787/ClappedHub.lua"
local source = game:HttpGet(LIBRARY_URL)
local Library = assert(loadstring(source), "Could not load the published UI library")()

local UI = Library.new({
	Name = "EXAMPLE HUB",
	Subtitle = "ULTIMATE BUYER SHOWCASE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(98, 183, 255),
	Theme = {
		Background = Color3.fromRGB(7, 10, 18),
		Window = Color3.fromRGB(13, 17, 28),
		Sidebar = Color3.fromRGB(10, 14, 24),
		Surface = Color3.fromRGB(22, 29, 44),
		SurfaceRaised = Color3.fromRGB(35, 46, 68),
		SurfaceHover = Color3.fromRGB(49, 66, 95),
		Text = Color3.fromRGB(244, 248, 255),
		TextMuted = Color3.fromRGB(163, 180, 208),
	},
	WindowSize = Vector2.new(780, 650),
	WindowMinSize = Vector2.new(480, 430),
	WindowMaxSize = Vector2.new(940, 800),
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false, -- Set true to demo the optional loading transition.
})

local function notify(title, content, color, icon)
	UI:Notify({
		Title = title,
		Content = content,
		Color = color or Color3.fromRGB(98, 183, 255),
		Icon = icon or "✓",
		Duration = 3,
	})
end

-- Example 1: layout, cards, labels, and notifications.
local overviewTab = UI:Tab({Name = "Example 1", Icon = "1", Description = "Layout, labels, buttons, and notifications."})
local overview = UI:Section({Tab = overviewTab, Name = "Product Overview", Description = "A clean starting point for a premium Roblox interface."})
overview:Label({Title = "Library status", Text = "ONLINE"})
overview:Label({Title = "Hosted version", Text = "GITHUB MAIN"})
overview:Label({Title = "Design system", Text = "CUSTOMIZABLE"})
overview:Button({Name = "Preview notification", Text = "PREVIEW", Description = "Show the animated notification component.", Callback = function()
	notify("Preview complete", "Your product can use notifications for clear user feedback.")
end})

-- Example 2: complete control gallery.
local controlsTab = UI:Tab({Name = "Example 2", Icon = "2", Description = "Toggle, slider, dropdown, textbox, color, and keybind controls."})
local controls = UI:Section({Tab = controlsTab, Name = "Control Gallery", Description = "All controls support callbacks, optional flags, and polished transitions."})
controls:Toggle({Name = "Feature toggle", Description = "Smooth on/off state with callback support.", Flag = "FeatureToggle", Default = true, Callback = function(value)
	print("Feature toggle:", value)
end})
controls:Slider({Name = "Intensity slider", Description = "Drag to select a numeric value.", Flag = "Intensity", Min = 0, Max = 100, Default = 72, Format = "%d%%", Callback = function(value)
	print("Intensity:", value)
end})
controls:Dropdown({Name = "Mode dropdown", Description = "Clean centered text with a font-safe design.", Flag = "Mode", Width = 165, Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Callback = function(value)
	print("Mode:", value)
end})
controls:TextBox({Name = "Text box", Description = "Padded input with focus styling and truncation.", Flag = "TextValue", Width = 165, Placeholder = "Enter text...", Default = "Example value", Callback = function(value)
	print("Text:", value)
end})
controls:ColorPicker({Name = "Color picker", Description = "Draggable picker with palette, hex, and RGB inputs.", Flag = "ColorValue", Default = Color3.fromRGB(98, 183, 255), Callback = function(value)
	print("Color:", value)
end})

-- Example 3: keybinds and returned control methods.
local keybindTab = UI:Tab({Name = "Example 3", Icon = "3", Description = "Toggle keys, hold keys, and programmatic control methods."})
local keybinds = UI:Section({Tab = keybindTab, Name = "Keybind Showcase", Description = "Click a key value to rebind it; press Escape to cancel."})
local methodToggle = keybinds:Toggle({Name = "Method demo", Flag = "MethodDemo", Callback = function(value)
	print("Method demo:", value)
end})
keybinds:Keybind({Name = "Toggle mode", Flag = "ToggleMode", Key = Enum.KeyCode.B, Mode = "Toggle", Callback = function(value)
	print("Toggle mode:", value)
end})
keybinds:Keybind({Name = "Hold mode", Flag = "HoldMode", Key = Enum.KeyCode.LeftControl, Mode = "Hold", Callback = function(value)
	print("Hold mode:", value)
end})
keybinds:Button({Name = "Set toggle from code", Text = "SET", Width = 125, Description = "Uses the returned toggle control's Set method.", Callback = function()
	methodToggle.Set(true)
	notify("Control updated", "The toggle was changed programmatically.")
end})

-- Example 4: live themes, backgrounds, icons, and layout.
local appearanceTab = UI:Tab({Name = "Example 4", Icon = "4", Description = "Runtime appearance and layout customization."})
local appearance = UI:Section({Tab = appearanceTab, Name = "Appearance Presets", Description = "Switch visual presets without rebuilding the interface."})
appearance:Dropdown({Name = "Accent preset", Width = 165, Options = {"Sky blue", "Rose pink", "Mint green", "Warm gold"}, Default = "Sky blue", Callback = function(value)
	local colors = {
		["Sky blue"] = Color3.fromRGB(98, 183, 255),
		["Rose pink"] = Color3.fromRGB(255, 112, 178),
		["Mint green"] = Color3.fromRGB(100, 220, 170),
		["Warm gold"] = Color3.fromRGB(245, 190, 80),
	}
	if colors[value] then UI:SetAccent(colors[value]) end
end})
appearance:Dropdown({Name = "Background preset", Width = 165, Options = {"Ocean", "Dark", "Single"}, Default = "Ocean", Callback = function(value)
	if value == "Single" then
		UI:SetBackgroundVisible(false)
	elseif value == "Dark" then
		UI:SetBackgroundImage("rbxassetid://78664802433772", 0.58)
		UI:SetBackgroundVisible(true)
	else
		UI:SetBackgroundImage("rbxassetid://78664802433772", 0.18)
		UI:SetBackgroundVisible(true)
	end
end})
appearance:Button({Name = "Resize window", Text = "RESIZE", Width = 125, Callback = function()
	UI:SetWindowSize(Vector2.new(840, 700))
end})
appearance:Button({Name = "Center window", Text = "CENTER", Width = 125, Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
end})
appearance:Button({Name = "Change icon", Text = "ICON", Width = 125, Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
	notify("Icon updated", "The main logo can be replaced at runtime.")
end})

-- Settings: built-in utility features and configuration storage.
local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Search, keybind panel, profile, and configuration features."})
local settings = UI:Section({Tab = settingsTab, Name = "Interface Utilities", Description = "Optional built-in utilities for a finished product."})
settings:KeybindListToggle({Name = "Show keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
local configs = UI:ConfigManager({Folder = "UltimateShowcaseConfigs", DefaultConfig = "Default"})
local configName = settings:TextBox({Name = "Config name", Width = 165, Default = "Default", Placeholder = "Enter config name..."})
settings:Button({Name = "Save configuration", Text = "SAVE", Width = 125, Callback = function()
	local success, message = configs:Save(configName.Get())
	notify("Save configuration", tostring(message), success and Color3.fromRGB(74, 205, 143) or Color3.fromRGB(235, 92, 112), success and "✓" or "!")
end})
settings:Button({Name = "Load configuration", Text = "LOAD", Width = 125, Callback = function()
	local success, message = configs:Load(configName.Get())
	notify("Load configuration", tostring(message), success and Color3.fromRGB(74, 205, 143) or Color3.fromRGB(235, 92, 112), success and "✓" or "!")
end})
settings:Button({Name = "List configurations", Text = "LIST", Width = 125, Callback = function()
	local names = configs:List()
	notify("Saved configurations", #names > 0 and table.concat(names, ", ") or "No configurations found.")
end})
settings:Button({Name = "Close showcase", Text = "CLOSE", Width = 125, Callback = function() UI:Destroy() end})

UI:Notify({
	Title = "Buyer showcase ready",
	Content = "Explore Example 1-4 and Settings to preview the complete library.",
	Icon = "✓",
	Duration = 5,
})
