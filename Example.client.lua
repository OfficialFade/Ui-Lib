-- Clapped Hub UI Lib - search, tabs, keybind picker, and keybind panel example
-- The commit URL keeps the executor from loading a stale cached library.
local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/e67d07c/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not compile ClappedHub.lua from GitHub")()

local UI = Library.new({
	Name = "CLAPPED HUB",
	Subtitle = "PRODUCTION UI EXAMPLE",
	Accent = Color3.fromRGB(78, 160, 255),
	ScriptType = "FREE", -- Change to "PAID" for a paid script badge.
	EnableLoadingMusic = true,
})

local combatTab = UI:Tab({
	Name = "Combat",
	Icon = "⚔",
	Description = "Combat-related controls.",
})

local combat = UI:Section({
	Tab = combatTab,
	Name = "Combat Controls",
	Description = "Search these controls or use their keybinds.",
})

combat:Button({
	Name = "Attack test",
	Text = "RUN",
	Description = "Runs a safe UI-only callback.",
	Callback = function()
		UI:Notify({
			Title = "Attack test",
			Content = "The button callback fired successfully.",
			Icon = "✓",
			Duration = 3,
		})
	end,
})

combat:Toggle({
	Name = "Auto mode",
	Default = false,
	Callback = function(enabled)
		print("Auto mode:", enabled)
	end,
})

combat:Keybind({
	Name = "Infinite Jump",
	Description = "Press the selected key to toggle this state.",
	Flag = "InfiniteJump",
	Key = Enum.KeyCode.V,
	Mode = "Toggle",
	Callback = function(enabled)
		print("Infinite Jump:", enabled)
	end,
})

local visualsTab = UI:Tab({
	Name = "Visuals",
	Icon = "◉",
	Description = "Visual interface settings.",
})

local visuals = UI:Section({
	Tab = visualsTab,
	Name = "Visual Controls",
	Description = "Controls are searchable from the bar above.",
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
	Name = "Theme style",
	Description = "Choose an interface style.",
	Flag = "ThemeStyle",
	Options = {"Ocean", "Midnight", "Violet"},
	Default = "Ocean",
	Callback = function(value)
		print("Theme style:", value)
	end,
})

visuals:ColorPicker({
	Name = "Accent color",
	Description = "Edit the accent with hex or RGB values.",
	Flag = "AccentColor",
	Default = Color3.fromRGB(78, 160, 255),
	Callback = function(value)
		print("Accent color:", value)
	end,
})

visuals:Keybind({
	Name = "Toggle visuals",
	Description = "Hold the selected key to enable this state.",
	Flag = "ToggleVisuals",
	Key = Enum.KeyCode.B,
	Mode = "Hold",
	Callback = function(enabled)
		print("Toggle visuals:", enabled)
	end,
})

local settingsTab = UI:Tab({
	Name = "Settings",
	Icon = "⚙",
	Description = "Library settings and keybind options.",
})

local settings = UI:Section({
	Tab = settingsTab,
	Name = "Library Settings",
	Description = "Open the draggable keybind list here.",
})

settings:KeybindListToggle({
	Name = "Show keybinds",
	Description = "Open the compact keybind panel.",
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

settings:Button({
	Name = "Test notification",
	Text = "SHOW",
	Description = "Shows a notification with the shared backdrop.",
	Callback = function()
		UI:Notify({
			Title = "Settings",
			Content = "Search, keybinds, and notifications are working.",
			Icon = "✦",
			Duration = 3,
		})
	end,
})

settings:TextBox({
	Name = "Profile name",
	Description = "Example text input control.",
	Flag = "ProfileName",
	Placeholder = "Type a name...",
	Default = "Clapped User",
	Callback = function(value)
		print("Profile name:", value)
	end,
})

UI:Notify({
	Title = "Interface ready",
	Content = "Try the search bar or open Show keybinds.",
	Icon = "✓",
	Duration = 4,
})
