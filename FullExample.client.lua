-- Clapped Hub UI Lib - full customization and controls showcase

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/9ee279e/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "MY CUSTOM HUB",
	Subtitle = "FULL FEATURE SHOWCASE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(120, 180, 255),
	Theme = {
		Window = Color3.fromRGB(14, 16, 25),
		Surface = Color3.fromRGB(24, 28, 42),
		SurfaceRaised = Color3.fromRGB(34, 40, 60),
		Text = Color3.fromRGB(242, 246, 255),
		TextMuted = Color3.fromRGB(160, 174, 200),
	},
	WindowSize = Vector2.new(720, 620),
	WindowPosition = UDim2.fromScale(0.5, 0.5),
	WindowMinSize = Vector2.new(480, 420),
	WindowMaxSize = Vector2.new(900, 760),
	AspectRatio = 1.15,
	CollapsibleSidebar = false,
	AutoCollapseSidebar = false,
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local Config = UI:ConfigManager({
	Folder = "MyCustomHubConfigs",
	DefaultConfig = "Default",
	OnStatus = function(success, message)
		print(success and "[Config]" or "[Config error]", message)
	end,
})

local overviewTab = UI:Tab({
	Name = "Overview",
	Icon = "⌂",
	Description = "Start here to explore the complete interface.",
})
local overview = UI:Section({
	Tab = overviewTab,
	Name = "Welcome",
	Description = "Every callback in this example only changes UI state or prints a value.",
})
overview:Label({Title = "Status", Text = "Interface online"})
overview:Button({
	Name = "Test notification",
	Text = "SHOW",
	Callback = function()
		UI:Notify({Title = "Hello", Content = "Your custom hub is running.", Icon = "✓", Duration = 3})
	end,
})

local controlsTab = UI:Tab({
	Name = "Controls",
	Icon = "◆",
	Description = "Toggle, slider, dropdown, text, color, and keybind examples.",
})
local controls = UI:Section({Tab = controlsTab, Name = "Control Showcase", Description = "All controls expose Set and Get methods where applicable."})

local demoToggle = controls:Toggle({
	Name = "Demo toggle",
	Flag = "DemoToggle",
	Default = false,
	Callback = function(value) print("Demo toggle:", value) end,
})
controls:Slider({
	Name = "Demo slider",
	Flag = "DemoSlider",
	Min = 0,
	Max = 100,
	Default = 65,
	Format = "%d%%",
	Callback = function(value) print("Demo slider:", value) end,
})
controls:Dropdown({
	Name = "Mode",
	Flag = "DemoMode",
	Options = {"Balanced", "Fast", "Quiet"},
	Default = "Balanced",
	Callback = function(value) print("Mode:", value) end,
})
controls:ColorPicker({
	Name = "Highlight color",
	Flag = "HighlightColor",
	Default = Color3.fromRGB(120, 180, 255),
	Callback = function(value) print("Highlight color:", value) end,
})
controls:TextBox({
	Name = "Display name",
	Flag = "DisplayName",
	Placeholder = "Type something...",
	Default = "Player",
	Live = true,
	Callback = function(value) print("Display name:", value) end,
})
controls:Keybind({
	Name = "Demo keybind",
	Flag = "DemoKeybind",
	Key = Enum.KeyCode.B,
	Mode = "Toggle",
	Callback = function(value) print("Demo keybind:", value) end,
})
controls:Keybind({
	Name = "Hold example",
	Key = Enum.KeyCode.LeftControl,
	Mode = "Hold",
	Callback = function(value) print("Hold example:", value) end,
})

local appearanceTab = UI:Tab({
	Name = "Appearance",
	Icon = "◉",
	Description = "Change the interface while it is running.",
})
local appearance = UI:Section({Tab = appearanceTab, Name = "Runtime Customization"})
appearance:Button({
	Name = "Resize window",
	Text = "RESIZE",
	Callback = function() UI:SetWindowSize(Vector2.new(780, 650)) end,
})
appearance:Button({
	Name = "Center window",
	Text = "CENTER",
	Callback = function() UI:SetWindowPosition(UDim2.fromScale(0.5, 0.5)) end,
})
appearance:Button({
	Name = "Change accent",
	Text = "ACCENT",
	Callback = function() UI:SetAccent(Color3.fromRGB(255, 110, 170)) end,
})
appearance:Button({
	Name = "Toggle background",
	Text = "HIDE",
	Callback = function() UI:SetBackgroundVisible(false) end,
})
appearance:Button({
	Name = "Reset demo toggle",
	Text = "RESET",
	Callback = function() demoToggle.Set(false) end,
})

local settingsTab = UI:Tab({Name = "Settings", Icon = "⚙", Description = "Visibility, keybinds, and config management."})
local settings = UI:Section({Tab = settingsTab, Name = "Interface Settings"})
settings:KeybindListToggle({Name = "Show keybinds", Default = false})
settings:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift, Mode = "Toggle"})
settings:Toggle({Name = "Search visible", Default = true, Callback = function(value) UI:SetSearchVisible(value) end})
settings:Toggle({Name = "Profile visible", Default = true, Callback = function(value) UI:SetProfileVisible(value) end})

local configName = settings:TextBox({Name = "Config name", Default = "Default", Placeholder = "Config name..."})
local function configMessage(title, success, message)
	UI:Notify({Title = title, Content = tostring(message), Icon = success and "✓" or "!", Duration = 3})
end
settings:Button({Name = "Save config", Text = "SAVE", Callback = function()
		local success, message = Config:Save(configName.Get())
		configMessage("Save config", success, message)
	end})
settings:Button({Name = "Load config", Text = "LOAD", Callback = function()
		local success, message = Config:Load(configName.Get())
		configMessage("Load config", success, message)
	end})
settings:Button({Name = "List configs", Text = "LIST", Callback = function()
		local names = Config:List()
		configMessage("Saved configs", true, #names > 0 and table.concat(names, ", ") or "No configs found.")
	end})

UI:Notify({Title = "Interface ready", Content = "Use the sidebar, search, RightShift, and the Appearance tab.", Icon = "✓", Duration = 4})

-- Other useful calls:
-- UI:SetIcon("rbxassetid://YOUR_IMAGE_ID")
-- UI:SetLogo("rbxassetid://YOUR_IMAGE_ID")
-- UI:SetHubVisible(true)
-- UI:ToggleHub()
-- UI:SetKeybindPanelVisible(true)
-- UI:Destroy()
