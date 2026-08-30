-- Ocean UI Lib by Fade - buyer-ready showcase
-- A clean, cache-free example for previewing the library's public API.

local LIBRARY_URL = "https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua"
local Library = assert(loadstring(game:HttpGet(LIBRARY_URL .. "?showcase=" .. os.clock())), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(800, 650),
	WindowMinSize = Vector2.new(500, 440),
	WindowMaxSize = Vector2.new(1000, 820),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local function toast(title, content, color)
	UI:Notify({
		Title = title,
		Content = content,
		Color = color or Color3.fromRGB(80, 175, 255),
		Icon = "✓",
		Duration = 3,
	})
end

local home = UI:Tab({Name = "Welcome", Icon = "⌂", Description = "A polished starting point for your next script."})
local intro = UI:Section({Tab = home, Name = "Product showcase", Description = "A complete example of the Ocean UI Lib experience."})
intro:Label({Title = "Library status", Text = "ONLINE"})
intro:Label({Title = "Release channel", Text = "GITHUB MAIN"})
intro:Label({Title = "Included features", Text = "CONTROLS • THEMES • CONFIGS"})
intro:Button({Name = "Test notification", Text = "TEST", Description = "Preview the animated notification system.", Callback = function()
	toast("Hello from Ocean UI", "Notifications are ready for your own callbacks.")
end})

local controlsTab = UI:Tab({Name = "Controls", Icon = "◆", Description = "Every essential control in one clean gallery."})
local controls = UI:Section({Tab = controlsTab, Name = "Control gallery", Description = "Toggle, slider, dropdown, textbox, color picker, and keybind examples."})
controls:Toggle({Name = "Feature toggle", Description = "A responsive on/off control.", Default = true, Callback = function(value)
	toast("Feature toggle", value and "Enabled" or "Disabled")
end})
controls:Slider({Name = "Intensity", Description = "A smooth numeric slider.", Min = 0, Max = 100, Default = 65, Format = "%d%%"})
controls:Dropdown({Name = "Mode", Description = "Bold, centered dropdown text.", Options = {"Balanced", "Performance", "Minimal"}, Default = "Balanced", Width = 170})
controls:TextBox({Name = "Text input", Description = "Clean padded input with focus styling.", Placeholder = "Type something...", Default = "Example", Width = 170})
controls:ColorPicker({Name = "Accent color", Description = "Drag the palette cursor and hue slider.", Default = Color3.fromRGB(80, 175, 255), Callback = function(color)
	UI:SetAccent(color)
end})
controls:Keybind({Name = "Toggle key", Description = "Press a key to trigger an action.", Key = Enum.KeyCode.RightShift, Mode = "Toggle", Callback = function(value)
	toast("Keybind", value and "Activated" or "Deactivated")
end})

local visualsTab = UI:Tab({Name = "Visuals", Icon = "✦", Description = "Runtime branding and appearance customization."})
local visuals = UI:Section({Tab = visualsTab, Name = "Branding controls", Description = "Change the look of the interface without rebuilding it."})
visuals:Dropdown({Name = "Accent preset", Options = {"Ocean", "Rose", "Mint", "Gold"}, Default = "Ocean", Width = 170, Callback = function(value)
	local colors = {
		Ocean = Color3.fromRGB(80, 175, 255),
		Rose = Color3.fromRGB(255, 105, 170),
		Mint = Color3.fromRGB(85, 220, 165),
		Gold = Color3.fromRGB(245, 190, 80),
	}
	UI:SetAccent(colors[value])
end})
visuals:Button({Name = "Swap logo", Text = "ICON", Width = 135, Callback = function()
	UI:SetIcon("rbxassetid://101595980825854")
	toast("Logo updated", "Brand icons can be changed at runtime.")
end})
visuals:Button({Name = "Resize window", Text = "RESIZE", Width = 135, Callback = function()
	UI:SetWindowSize(Vector2.new(860, 700))
end})
visuals:Button({Name = "Center window", Text = "CENTER", Width = 135, Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
end})

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Configuration and optional utility features."})
local settings = UI:Section({Tab = settingsTab, Name = "Library settings", Description = "Show how a finished product can expose preferences."})
settings:Toggle({Name = "Search bar", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile card", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})
settings:KeybindListToggle({Name = "Keybind panel", Default = false})
settings:HubToggleKeybind({Name = "Hub key", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Button({Name = "Reset position", Text = "RESET", Width = 135, Callback = function()
	UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5))
	UI:SetWindowSize(Vector2.new(800, 650))
	toast("Layout reset", "The showcase returned to its default layout.")
end})

UI:Notify({Title = "Showcase ready", Content = "Explore Welcome, Controls, Visuals, and Settings.", Icon = "✓", Duration = 5})
