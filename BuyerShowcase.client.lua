-- Clapped Hub UI Lib - buyer presentation showcase
-- Replace LIBRARY_URL with the raw URL of your latest published ClappedHub.lua.

local LIBRARY_URL = "YOUR_RAW_URL/ClappedHub.lua"
local source = game:HttpGet(LIBRARY_URL)
local Library = assert(loadstring(source), "Could not load the latest UI library")()

local UI = Library.new({
	Name = "EXAMPLE HUB",
	Subtitle = "PREMIUM UI LIBRARY",
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
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false, -- Set true when you want to demo the optional loader.
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

-- Buyer demo: layout and polish
local dashboardTab = UI:Tab({
	Name = "Dashboard",
	Icon = "⌂",
	Description = "A clean dashboard layout for a premium script.",
})
local dashboard = UI:Section({
	Tab = dashboardTab,
	Name = "Welcome",
	Description = "A polished starting point for your own product interface.",
})
dashboard:Label({Title = "Interface", Text = "ONLINE"})
dashboard:Label({Title = "Design system", Text = "CUSTOMIZABLE"})
dashboard:Button({
	Name = "Preview notification",
	Text = "PREVIEW",
	Description = "Shows the animated feedback component.",
	Callback = function()
		notify("Preview complete", "Notifications are ready for your callbacks.")
	end,
})

-- Buyer demo: controls
local controlsTab = UI:Tab({
	Name = "Controls",
	Icon = "◆",
	Description = "A complete set of modern input components.",
})
local controls = UI:Section({
	Tab = controlsTab,
	Name = "Control Gallery",
	Description = "Try each component to see its interaction and state handling.",
})
controls:Toggle({Name = "Feature toggle", Flag = "FeatureToggle", Default = true, Callback = function(value)
	print("Feature toggle:", value)
end})
controls:Slider({Name = "Intensity", Flag = "Intensity", Min = 0, Max = 100, Default = 72, Format = "%d%%", Callback = function(value)
	print("Intensity:", value)
end})
controls:Dropdown({Name = "Mode selector", Flag = "ModeSelector", Width = 160, Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Callback = function(value)
	print("Mode:", value)
end})
controls:TextBox({Name = "Text input", Flag = "TextInput", Width = 160, Placeholder = "Enter text...", Default = "Example", Callback = function(value)
	print("Text:", value)
end})
controls:ColorPicker({Name = "Color picker", Flag = "ColorPicker", Default = Color3.fromRGB(96, 180, 255), Callback = function(value)
	print("Color:", value)
end})

-- Buyer demo: keybinds and runtime customization
local customizationTab = UI:Tab({
	Name = "Customization",
	Icon = "◉",
	Description = "Show buyers how much of the interface can be customized.",
})
local customization = UI:Section({
	Tab = customizationTab,
	Name = "Runtime Controls",
	Description = "These controls update the interface without rebuilding it.",
})
customization:Keybind({Name = "Demo toggle key", Key = Enum.KeyCode.B, Mode = "Toggle", Callback = function(value)
	print("Toggle key:", value)
end})
customization:Keybind({Name = "Demo hold key", Key = Enum.KeyCode.LeftControl, Mode = "Hold", Callback = function(value)
	print("Hold key:", value)
end})
customization:Button({Name = "Pink accent", Text = "APPLY", Width = 120, Callback = function()
	UI:SetAccent(Color3.fromRGB(255, 112, 178))
	notify("Theme updated", "Accent preset applied.", Color3.fromRGB(255, 112, 178))
end})
customization:Button({Name = "Reset accent", Text = "RESET", Width = 120, Callback = function()
	UI:SetAccent(Color3.fromRGB(96, 180, 255))
	notify("Theme reset", "Default accent restored.")
end})
customization:Button({Name = "Change icon", Text = "ICON", Width = 120, Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
	notify("Icon updated", "The hub icon can be replaced at runtime.")
end})
customization:Button({Name = "Move and resize", Text = "LAYOUT", Width = 120, Callback = function()
	UI:SetWindowSize(Vector2.new(820, 680))
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.48))
end})

-- Buyer demo: utility features
local settingsTab = UI:Tab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Search, keybind panel, visibility, and cleanup options.",
})
local settings = UI:Section({Tab = settingsTab, Name = "Utility Features", Description = "Built-in utilities reduce the amount of setup your product needs."})
settings:KeybindListToggle({Name = "Show keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:Button({Name = "Hide background", Text = "HIDE", Width = 120, Callback = function() UI:SetBackgroundVisible(false) end})
settings:Button({Name = "Destroy showcase", Text = "CLOSE", Width = 120, Callback = function() UI:Destroy() end})

UI:Notify({
	Title = "Buyer showcase ready",
	Content = "Explore Dashboard, Controls, Customization, and Settings.",
	Icon = "✓",
	Duration = 5,
})

