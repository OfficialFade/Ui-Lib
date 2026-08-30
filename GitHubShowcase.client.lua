-- Clapped Hub UI Lib - GitHub-hosted full showcase
-- This script loads the latest library from the repository's main branch.

local LIBRARY_URL = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua"
local source = game:HttpGet(LIBRARY_URL)
local Library = assert(loadstring(source), "Could not load Clapped Hub UI Lib")()

local UI = Library.new({
	Name = "EXAMPLE HUB",
	Subtitle = "GITHUB SHOWCASE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(96, 180, 255),
	Theme = {
		Background = Color3.fromRGB(7, 10, 18),
		Window = Color3.fromRGB(13, 17, 28),
		Sidebar = Color3.fromRGB(10, 14, 24),
		Surface = Color3.fromRGB(22, 29, 44),
		SurfaceRaised = Color3.fromRGB(34, 45, 67),
		SurfaceHover = Color3.fromRGB(48, 64, 92),
		Text = Color3.fromRGB(244, 248, 255),
		TextMuted = Color3.fromRGB(163, 179, 207),
	},
	WindowSize = Vector2.new(760, 640),
	WindowMinSize = Vector2.new(480, 430),
	WindowMaxSize = Vector2.new(920, 780),
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local function notify(title, content, color, icon)
	UI:Notify({
		Title = title,
		Content = content,
		Color = color or Color3.fromRGB(96, 180, 255),
		Icon = icon or "✓",
		Duration = 3,
	})
end

local example1Tab = UI:Tab({Name = "Example 1", Icon = "1", Description = "Layout, labels, buttons, and notifications."})
local example1 = UI:Section({Tab = example1Tab, Name = "Basic Components", Description = "A clean foundation for any script panel."})
example1:Label({Title = "Library status", Text = "ONLINE"})
example1:Label({Title = "Release source", Text = "GITHUB MAIN"})
example1:Button({Name = "Notification demo", Text = "TEST", Description = "Preview an animated notification.", Callback = function()
	notify("Example 1", "The notification system is working.")
end})

local example2Tab = UI:Tab({Name = "Example 2", Icon = "2", Description = "Every standard input component in one gallery."})
local example2 = UI:Section({Tab = example2Tab, Name = "Control Gallery", Description = "Toggle, slider, dropdown, text, color, and keybind examples."})
example2:Toggle({Name = "Feature toggle", Flag = "FeatureToggle", Default = true, Callback = function(value) print("Feature toggle:", value) end})
example2:Slider({Name = "Intensity", Flag = "Intensity", Min = 0, Max = 100, Default = 72, Format = "%d%%", Callback = function(value) print("Intensity:", value) end})
example2:Dropdown({Name = "Mode selector", Flag = "ModeSelector", Width = 160, Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Callback = function(value) print("Mode:", value) end})
example2:TextBox({Name = "Text input", Flag = "TextInput", Width = 160, Placeholder = "Enter text...", Default = "Example", Callback = function(value) print("Text:", value) end})
example2:ColorPicker({Name = "Color picker", Flag = "ColorPicker", Default = Color3.fromRGB(96, 180, 255), Callback = function(value) print("Color:", value) end})

local example3Tab = UI:Tab({Name = "Example 3", Icon = "3", Description = "Keybind modes and programmatic control changes."})
local example3 = UI:Section({Tab = example3Tab, Name = "Keybind Showcase", Description = "Toggle and Hold modes are supported."})
local demoToggle = example3:Toggle({Name = "Programmatic toggle", Flag = "ProgrammaticToggle", Callback = function(value) print("Programmatic toggle:", value) end})
example3:Keybind({Name = "Toggle keybind", Key = Enum.KeyCode.B, Mode = "Toggle", Callback = function(value) print("Toggle key:", value) end})
example3:Keybind({Name = "Hold keybind", Key = Enum.KeyCode.LeftControl, Mode = "Hold", Callback = function(value) print("Hold key:", value) end})
example3:Button({Name = "Set control from code", Text = "SET", Description = "Uses the returned control's Set method.", Callback = function()
	demoToggle.Set(true)
	notify("Example 3", "The toggle was changed programmatically.")
end})

local example4Tab = UI:Tab({Name = "Example 4", Icon = "4", Description = "Runtime theme, layout, icon, and background controls."})
local example4 = UI:Section({Tab = example4Tab, Name = "Customization Showcase", Description = "Change the interface without rebuilding it."})
example4:Button({Name = "Pink accent", Text = "ACCENT", Width = 120, Callback = function()
	UI:SetAccent(Color3.fromRGB(255, 112, 178))
	notify("Accent updated", "Pink accent applied.", Color3.fromRGB(255, 112, 178))
end})
example4:Button({Name = "Reset accent", Text = "RESET", Width = 120, Callback = function()
	UI:SetAccent(Color3.fromRGB(96, 180, 255))
end})
example4:Button({Name = "Resize window", Text = "RESIZE", Width = 120, Callback = function()
	UI:SetWindowSize(Vector2.new(820, 680))
end})
example4:Button({Name = "Change icon", Text = "ICON", Width = 120, Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
end})
example4:Button({Name = "Hide background", Text = "HIDE", Width = 120, Callback = function()
	UI:SetBackgroundVisible(false)
end})

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Built-in visibility and keybind utilities."})
local settings = UI:Section({Tab = settingsTab, Name = "Utility Features", Description = "Optional controls for the showcase."})
settings:KeybindListToggle({Name = "Show keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:Button({Name = "Restore background", Text = "SHOW", Width = 120, Callback = function()
	UI:SetBackgroundVisible(true)
	UI:SetBackgroundImage("rbxassetid://78664802433772", 0.18)
end})
settings:Button({Name = "Close showcase", Text = "CLOSE", Width = 120, Callback = function() UI:Destroy() end})

UI:Notify({Title = "Showcase ready", Content = "Loaded from OfficialFade/Ui-Lib main.", Icon = "✓", Duration = 5})

