-- Clapped Hub UI Lib - visual showcase
-- This showcase demonstrates UI features only. Replace demo callbacks with your own logic.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/9ee279e/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "EXAMPLE SHOWCASE",
	Subtitle = "CUSTOM UI EXAMPLE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(110, 190, 255),
	Theme = {
		Background = Color3.fromRGB(7, 10, 18),
		Window = Color3.fromRGB(13, 17, 28),
		Surface = Color3.fromRGB(23, 30, 46),
		SurfaceRaised = Color3.fromRGB(34, 45, 68),
		SurfaceHover = Color3.fromRGB(48, 65, 94),
		Text = Color3.fromRGB(242, 247, 255),
		TextMuted = Color3.fromRGB(163, 180, 208),
	},
	WindowSize = Vector2.new(720, 620),
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	WindowMinSize = Vector2.new(450, 420),
	WindowMaxSize = Vector2.new(900, 760),
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	SidebarExpandedWidth = 170,
	SidebarCollapsedWidth = 58,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = true, -- Set false to disable the optional loading transition.
})

local function notify(title, content, color, icon)
	UI:Notify({
		Title = title,
		Content = content,
		Color = color,
		Icon = icon or "✦",
		Duration = 3,
	})
end

-- Overview tab
local homeTab = UI:Tab({
	Name = "Overview",
	Icon = "⌂",
	Description = "A quick tour of the example interface.",
})
local home = UI:Section({
	Tab = homeTab,
	Name = "Welcome",
	Description = "Hover the sidebar, search for controls, and open each showcase tab.",
})
home:Label({Title = "Library status", Text = "ONLINE"})
home:Label({Title = "Current theme", Text = "Custom Ocean"})
home:Button({
	Name = "Notification demo",
	Text = "TEST",
	Description = "Preview the animated notification system.",
	Callback = function()
		notify("Showcase notification", "Everything is working correctly.", Color3.fromRGB(110, 190, 255), "✓")
	end,
})

-- Controls tab
local controlsTab = UI:Tab({
	Name = "Controls",
	Icon = "◆",
	Description = "Examples of every standard input control.",
})
local controls = UI:Section({
	Tab = controlsTab,
	Name = "Interactive Controls",
	Description = "Each control supports callbacks and flag state.",
})
controls:Toggle({
	Name = "Example toggle",
	Description = "A smooth animated on/off control.",
	Flag = "ExampleToggle",
	Default = true,
	Callback = function(value) print("Example toggle:", value) end,
})
controls:Slider({
	Name = "Example slider",
	Description = "Drag to change a numeric value.",
	Flag = "ExampleSlider",
	Min = 0,
	Max = 100,
	Default = 50,
	Format = "%d%%",
	Callback = function(value) print("Example slider:", value) end,
})
controls:Dropdown({
	Name = "Example dropdown",
	Description = "The clean dropdown has no unsupported glyphs.",
	Width = 150,
	Flag = "ExampleDropdown",
	Options = {"Balanced", "Performance", "Minimal"},
	Default = "Balanced",
	Callback = function(value) print("Example dropdown:", value) end,
})
controls:TextBox({
	Name = "Example text box",
	Description = "Focus the field to see the highlighted border.",
	Width = 170,
	Flag = "ExampleText",
	Placeholder = "Enter a value...",
	Default = "Showcase",
	Live = true,
	Callback = function(value) print("Example text:", value) end,
})
controls:ColorPicker({
	Name = "Example color",
	Description = "Pick a color using the palette, hex, or RGB fields.",
	Flag = "ExampleColor",
	Default = Color3.fromRGB(110, 190, 255),
	Callback = function(value) print("Example color:", value) end,
})
controls:Keybind({
	Name = "Toggle keybind",
	Description = "Press the selected key to toggle the demo state.",
	Key = Enum.KeyCode.B,
	Mode = "Toggle",
	Callback = function(value) print("Toggle keybind:", value) end,
})
controls:Keybind({
	Name = "Hold keybind",
	Description = "Hold the selected key to activate the demo state.",
	Key = Enum.KeyCode.LeftControl,
	Mode = "Hold",
	Callback = function(value) print("Hold keybind:", value) end,
})

-- Appearance tab
local appearanceTab = UI:Tab({
	Name = "Appearance",
	Icon = "◉",
	Description = "Change the hub while it is running.",
})
local appearance = UI:Section({
	Tab = appearanceTab,
	Name = "Runtime Appearance",
	Description = "These buttons demonstrate the public customization methods.",
})
appearance:Button({Name = "Pink accent", Text = "APPLY", Callback = function()
	UI:SetAccent(Color3.fromRGB(255, 110, 175))
	notify("Accent updated", "The accent color changed.", Color3.fromRGB(255, 110, 175))
end})
appearance:Button({Name = "Blue accent", Text = "RESET", Callback = function()
	UI:SetAccent(Color3.fromRGB(110, 190, 255))
	notify("Accent reset", "The default showcase accent was restored.", Color3.fromRGB(110, 190, 255))
end})
appearance:Button({Name = "Resize window", Text = "RESIZE", Callback = function()
	UI:SetWindowSize(Vector2.new(820, 680))
end})
appearance:Button({Name = "Center window", Text = "CENTER", Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
end})
appearance:Button({Name = "Hide background", Text = "HIDE", Callback = function()
	UI:SetBackgroundVisible(false)
end})
appearance:Button({Name = "Change icon", Text = "ICON", Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
	notify("Icon updated", "The main hub icon was updated.", Color3.fromRGB(110, 190, 255))
end})

-- Settings tab
local settingsTab = UI:Tab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Sidebar, search, keybind panel, and cleanup options.",
})
local settings = UI:Section({Tab = settingsTab, Name = "Interface Settings"})
settings:KeybindListToggle({Name = "Show keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Toggle({Name = "Search bar visible", Default = true, Callback = function(value)
	UI:SetSearchVisible(value)
end})
settings:Toggle({Name = "Profile card visible", Default = true, Callback = function(value)
	UI:SetProfileVisible(value)
end})
settings:Button({Name = "Destroy interface", Text = "CLOSE", Callback = function()
	UI:Destroy()
end})

UI:Notify({
	Title = "Showcase ready",
	Content = "Move your mouse off the sidebar to see it collapse cleanly.",
	Icon = "✓",
	Duration = 5,
})
