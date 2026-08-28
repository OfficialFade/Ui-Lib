-- Clapped Hub UI Lib - complete feature showcase
-- This example only demonstrates UI callbacks and presentation state.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/9ee279e/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "CLAPPED HUB",
	Subtitle = "COMPLETE UI SHOWCASE",
	Accent = Color3.fromRGB(78, 160, 255),
	ScriptType = "FREE", -- Change to "PAID" for the paid-script badge.
	ProfileUserName = "UI Library Tester",
	BackgroundImage = "rbxassetid://78664802433772",
	BackgroundImageTransparency = 0.18,
	EnableLoadingMusic = true, -- Shows the built-in 11-second loading transition.
})

local Config = UI:ConfigManager({
	Folder = "ClappedHubConfigs",
	DefaultConfig = "Default",
	OnStatus = function(success, message)
		print(success and "[Config]" or "[Config error]", message)
	end,
})

-- Combat tab: label, button, toggle, slider, and toggle keybind.
local combatTab = UI:Tab({
	Name = "Combat",
	Icon = "⚔",
	Description = "A complete example of action controls.",
})

local combat = UI:Section({
	Tab = combatTab,
	Name = "Combat Controls",
	Description = "Every callback below is safe and UI-only.",
})

combat:Label({
	Title = "Status",
	Text = "Presentation layer online.",
})

combat:Button({
	Name = "Action button",
	Text = "RUN",
	Description = "Tests a standard button callback.",
	Callback = function()
		UI:Notify({
			Title = "Action button",
			Content = "The button callback fired successfully.",
			Icon = "✓",
			Duration = 3,
		})
	end,
})

local autoMode = combat:Toggle({
	Name = "Auto mode",
	Flag = "AutoMode",
	Default = false,
	Callback = function(enabled)
		print("Auto mode:", enabled)
	end,
})

combat:Slider({
	Name = "Attack power",
	Flag = "AttackPower",
	Min = 0,
	Max = 100,
	Default = 50,
	Format = "%d%%",
	Callback = function(value)
		print("Attack power:", value)
	end,
})

combat:Keybind({
	Name = "Combat mode",
	Description = "Click the key value to choose another key.",
	Flag = "CombatMode",
	Key = Enum.KeyCode.V,
	Mode = "Toggle",
	Callback = function(enabled)
		print("Combat mode:", enabled)
	end,
})

-- Visuals tab: dropdown, color picker, slider, toggle, text input, and hold keybind.
local visualsTab = UI:Tab({
	Name = "Visuals",
	Icon = "◉",
	Description = "Color, display, and input examples.",
})

local visuals = UI:Section({
	Tab = visualsTab,
	Name = "Visual Controls",
	Description = "Try searching for any of these controls.",
})

visuals:Toggle({
	Name = "Ambient glow",
	Flag = "AmbientGlow",
	Default = true,
	Callback = function(enabled)
		print("Ambient glow:", enabled)
	end,
})

visuals:Slider({
	Name = "Interface intensity",
	Flag = "InterfaceIntensity",
	Min = 0,
	Max = 100,
	Default = 72,
	Format = "%d%%",
	Callback = function(value)
		print("Interface intensity:", value)
	end,
})

visuals:Dropdown({
	Name = "Movement state",
	Description = "Choose an option from the contained menu.",
	Flag = "MovementState",
	Options = {
		"Idle",
		"Walking",
		"Running",
		"Jumping",
	},
	Default = "Idle",
	Callback = function(value)
		print("Movement state:", value)
	end,
})

visuals:Dropdown({
	Name = "Theme style",
	Flag = "ThemeStyle",
	Options = {"Ocean", "Midnight", "Violet"},
	Default = "Ocean",
	Callback = function(value)
		print("Theme style:", value)
	end,
})

visuals:ColorPicker({
	Name = "Accent color",
	Description = "Test the palette, hue fade, hex, and RGB inputs.",
	Flag = "AccentColor",
	Default = Color3.fromRGB(78, 160, 255),
	Callback = function(value)
		print("Accent color:", value)
	end,
})

visuals:TextBox({
	Name = "Display name",
	Description = "Test text input and the live callback.",
	Flag = "DisplayName",
	Placeholder = "Type a display name...",
	Default = "Clapped User",
	Live = true,
	Callback = function(value)
		print("Display name:", value)
	end,
})

visuals:Keybind({
	Name = "Visual hold mode",
	Description = "Hold the selected key to enable this state.",
	Flag = "VisualHoldMode",
	Key = Enum.KeyCode.B,
	Mode = "Hold",
	Callback = function(enabled)
		print("Visual hold mode:", enabled)
	end,
})

-- Settings tab: notifications, keybind list, hub key, and programmatic examples.
local settingsTab = UI:Tab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Library configuration and utility controls.",
})

local settings = UI:Section({
	Tab = settingsTab,
	Name = "Library Settings",
	Description = "The hub key and keybind panel can be changed here.",
})

settings:KeybindListToggle({
	Name = "Show keybinds",
	Description = "Open the compact draggable keybind panel.",
	Default = false,
})

settings:HubToggleKeybind({
	Name = "Toggle hub",
	Description = "Press the selected key to show or hide the hub.",
	Flag = "HubToggle",
	Key = Enum.KeyCode.RightShift,
	Callback = function(visible)
		print("Hub visible:", visible)
	end,
})

local configName = settings:TextBox({
	Name = "Config name",
	Description = "Choose the file name used for save and load.",
	Placeholder = "Default",
	Default = "Default",
})

local function configNotice(title: string, success: boolean, message: string)
	UI:Notify({
		Title = title,
		Content = message,
		Icon = success and "✓" or "!",
		Color = success and Color3.fromRGB(74, 205, 143) or Color3.fromRGB(235, 92, 112),
		Duration = 3,
	})
end

settings:Button({
	Name = "Save config",
	Text = "SAVE",
	Description = "Save all current control values to disk.",
	Callback = function()
		local success, message = Config:Save(configName.Get())
		configNotice("Config save", success, message)
	end,
})

settings:Button({
	Name = "Load config",
	Text = "LOAD",
	Description = "Restore saved controls, keys, and panel state.",
	Callback = function()
		local success, message = Config:Load(configName.Get())
		configNotice("Config load", success, message)
	end,
})

settings:Button({
	Name = "Delete config",
	Text = "DELETE",
	Description = "Remove the selected config file.",
	Callback = function()
		local success, message = Config:Delete(configName.Get())
		configNotice("Config delete", success, message)
	end,
})

settings:Button({
	Name = "Notification test",
	Text = "SHOW",
	Description = "Shows a custom notification with the shared backdrop.",
	Callback = function()
		UI:Notify({
			Title = "Custom notification",
			Content = "Notifications fade in and out smoothly.",
			Icon = "✦",
			Color = Color3.fromRGB(156, 211, 255),
			Duration = 4,
		})
	end,
})

settings:Button({
	Name = "Set toggle example",
	Text = "SET",
	Description = "Demonstrates changing a control from a callback.",
	Callback = function()
		autoMode.Set(true)
		UI:Notify({
			Title = "Control updated",
			Content = "Auto mode was enabled from another button.",
			Icon = "✓",
			Duration = 3,
		})
	end,
})

-- About tab: informational content and a status callback.
local aboutTab = UI:Tab({
	Name = "About",
	Icon = "ⓘ",
	Description = "Information about this library example.",
})

local about = UI:Section({
	Tab = aboutTab,
	Name = "Clapped Hub UI Lib",
	Description = "A complete production-style interface showcase.",
})

about:Label({
	Title = "Features",
	Text = "Tabs, search, controls, keybinds, notifications, and smooth motion.",
})

about:Button({
	Name = "Library status",
	Text = "CHECK",
	Description = "Displays a status notification.",
	Callback = function()
		UI:Notify({
			Title = "Library status",
			Content = "Clapped Hub UI Lib is running successfully.",
			Icon = "✓",
			Duration = 3,
		})
	end,
})

UI:Notify({
	Title = "Interface ready",
	Content = "Use the sidebar, search bar, keybind panel, or RightShift.",
	Icon = "✓",
	Duration = 4,
})

-- Available from your own callbacks when needed:
-- UI:ToggleHub()
-- UI:SetHubVisible(true)
-- UI:SetKeybindPanelVisible(true)
-- UI:Destroy()
