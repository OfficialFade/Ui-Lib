-- Clapped Hub UI Lib - labeled showcase script
-- Demo callbacks only: use this file to present the library's UI features.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/9ee279e/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "EXAMPLE HUB",
	Subtitle = "UI LIBRARY SHOWCASE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(92, 175, 255),
	WindowSize = Vector2.new(720, 620),
	WindowMinSize = Vector2.new(450, 420),
	WindowMaxSize = Vector2.new(900, 760),
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = true, -- Change to false to disable the optional loader.
})

local function notice(title, content, color)
	UI:Notify({
		Title = title,
		Content = content,
		Icon = "✓",
		Color = color or Color3.fromRGB(92, 175, 255),
		Duration = 3,
	})
end

-- Example 1: basic layout, labels, buttons, and notifications.
local example1Tab = UI:Tab({
	Name = "Example 1",
	Icon = "1",
	Description = "Basic layout and feedback components.",
})
local example1 = UI:Section({
	Tab = example1Tab,
	Name = "Basic Components",
	Description = "Use sections to group related controls into clean cards.",
})
example1:Label({Title = "Library status", Text = "READY"})
example1:Label({Title = "Version", Text = "Showcase build"})
example1:Button({
	Name = "Notification example",
	Text = "TEST",
	Description = "Displays an animated notification.",
	Callback = function()
		notice("Example 1", "The notification system is working.")
	end,
})

-- Example 2: standard controls.
local example2Tab = UI:Tab({
	Name = "Example 2",
	Icon = "2",
	Description = "Toggles, sliders, dropdowns, text boxes, and colors.",
})
local example2 = UI:Section({
	Tab = example2Tab,
	Name = "Input Controls",
	Description = "Every control supports a callback and optional flag.",
})
example2:Toggle({
	Name = "Example toggle",
	Flag = "ExampleToggle",
	Default = false,
	Callback = function(value) print("Toggle value:", value) end,
})
example2:Slider({
	Name = "Example slider",
	Flag = "ExampleSlider",
	Min = 0,
	Max = 100,
	Default = 50,
	Format = "%d%%",
	Callback = function(value) print("Slider value:", value) end,
})
example2:Dropdown({
	Name = "Example dropdown",
	Width = 150,
	Flag = "ExampleDropdown",
	Options = {"First option", "Second option", "Third option"},
	Default = "First option",
	Callback = function(value) print("Dropdown value:", value) end,
})
example2:TextBox({
	Name = "Example text box",
	Width = 150,
	Flag = "ExampleTextBox",
	Placeholder = "Type here...",
	Default = "Example text",
	Callback = function(value) print("Text value:", value) end,
})
example2:ColorPicker({
	Name = "Example color picker",
	Flag = "ExampleColor",
	Default = Color3.fromRGB(92, 175, 255),
	Callback = function(value) print("Color value:", value) end,
})

-- Example 3: keybinds and programmatic control changes.
local example3Tab = UI:Tab({
	Name = "Example 3",
	Icon = "3",
	Description = "Toggle keys, hold keys, and control methods.",
})
local example3 = UI:Section({
	Tab = example3Tab,
	Name = "Keybind Components",
	Description = "Keybind pickers can use Toggle or Hold mode.",
})
local programmaticToggle = example3:Toggle({
	Name = "Programmatic toggle",
	Flag = "ProgrammaticToggle",
	Callback = function(value) print("Programmatic toggle:", value) end,
})
example3:Keybind({
	Name = "Toggle keybind",
	Key = Enum.KeyCode.B,
	Mode = "Toggle",
	Callback = function(value) print("Toggle key:", value) end,
})
example3:Keybind({
	Name = "Hold keybind",
	Key = Enum.KeyCode.LeftControl,
	Mode = "Hold",
	Callback = function(value) print("Hold key:", value) end,
})
example3:Button({
	Name = "Set toggle from code",
	Text = "SET",
	Description = "Demonstrates a returned control's Set method.",
	Callback = function()
		programmaticToggle.Set(true)
		notice("Example 3", "The toggle was changed from a button.")
	end,
})

-- Example 4: theme, layout, sidebar, and visibility customization.
local example4Tab = UI:Tab({
	Name = "Example 4",
	Icon = "4",
	Description = "Runtime customization and window controls.",
})
local example4 = UI:Section({
	Tab = example4Tab,
	Name = "Customization Components",
	Description = "Try changing the interface without rebuilding it.",
})
example4:Button({Name = "Change accent", Text = "ACCENT", Callback = function()
	UI:SetAccent(Color3.fromRGB(255, 110, 175))
	notice("Example 4", "Accent color updated.", Color3.fromRGB(255, 110, 175))
end})
example4:Button({Name = "Resize window", Text = "RESIZE", Callback = function()
	UI:SetWindowSize(Vector2.new(820, 680))
end})
example4:Button({Name = "Center window", Text = "CENTER", Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
end})
example4:Button({Name = "Change icon", Text = "ICON", Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
	notice("Example 4", "Main icon updated.")
end})
example4:Button({Name = "Hide background", Text = "HIDE", Callback = function()
	UI:SetBackgroundVisible(false)
end})

local settingsTab = UI:Tab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Optional utility controls for the showcase.",
})
local settings = UI:Section({Tab = settingsTab, Name = "Optional Features"})
settings:KeybindListToggle({Name = "Show keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
local backgroundPresets = {
	["Single background"] = {Image = "", Transparency = 1},
	["Ocean background"] = {Image = "rbxassetid://78664802433772", Transparency = 0.18},
	["Dark background"] = {Image = "rbxassetid://78664802433772", Transparency = 0.55},
}
settings:Dropdown({
	Name = "Background style",
	Description = "Use one clean background or choose from multiple presets.",
	Width = 150,
	Options = {"Single background", "Ocean background", "Dark background"},
	Default = "Ocean background",
	Callback = function(value)
		local preset = backgroundPresets[value]
		if not preset then return end
		if value == "Single background" then
			UI:SetBackgroundVisible(false)
		else
			UI:SetBackgroundImage(preset.Image, preset.Transparency)
			UI:SetBackgroundVisible(true)
		end
	end,
})
settings:Dropdown({
	Name = "Accent preset",
	Description = "Choose the highlight color used by the interface.",
	Width = 150,
	Options = {"Sky blue", "Rose pink", "Mint green", "Warm gold"},
	Default = "Sky blue",
	Callback = function(value)
		local accents = {
			["Sky blue"] = Color3.fromRGB(92, 175, 255),
			["Rose pink"] = Color3.fromRGB(255, 110, 175),
			["Mint green"] = Color3.fromRGB(100, 220, 170),
			["Warm gold"] = Color3.fromRGB(245, 190, 80),
		}
		if accents[value] then UI:SetAccent(accents[value]) end
	end,
})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value)
	UI:SetSearchVisible(value)
end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value)
	UI:SetProfileVisible(value)
end})

UI:Notify({
	Title = "Example showcase ready",
	Content = "Open Example 1-4 to preview the library features.",
	Icon = "✓",
	Duration = 5,
})
