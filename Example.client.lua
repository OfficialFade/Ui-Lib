-- Clapped Hub UI Lib - test example
-- Always fetch the immutable commit so an old local ModuleScript or executor
-- cache cannot silently load a previous version.
local source = game:HttpGet(
	"https://raw.githubusercontent.com/OfficialFade/Ui-Lib/686ce39/ClappedHub.lua"
)
local loader = loadstring(source)
assert(loader, "Could not compile ClappedHub.lua from GitHub")
local Library = loader()

local UI = Library.new({
	Name = "CLAPPED HUB",
	Subtitle = "UI LIBRARY SHOWCASE",
	Accent = Color3.fromRGB(78, 160, 255),
})

local dashboard = UI:Tab({
	Name = "Dashboard",
	Icon = "⌂",
	Description = "A polished showcase of the interface system.",
})

local controls = UI:Section({
	Tab = dashboard,
	Name = "Interactive Controls",
	Description = "These controls demonstrate the interface system.",
})

controls:Button({
	Name = "Notification test",
	Text = "SHOW",
	Description = "Test the animated notification stack.",
	Callback = function()
		UI:Notify({
			Title = "Button clicked",
			Content = "The notification system is working.",
			Icon = "✦",
			Duration = 3,
		})
	end,
})

controls:Toggle({
	Name = "Ambient glow",
	Description = "Demonstrates toggle state changes.",
	Flag = "AmbientGlow",
	Default = true,
	Callback = function(enabled)
		print("Ambient glow:", enabled)
	end,
})

controls:Slider({
	Name = "Interface intensity",
	Description = "Demonstrates slider interaction.",
	Flag = "InterfaceIntensity",
	Min = 0,
	Max = 100,
	Default = 72,
	Format = "%d%%",
	Callback = function(value)
		print("Interface intensity:", value)
	end,
})

local aboutTab = UI:Tab({
	Name = "About",
	Icon = "ⓘ",
	Description = "Information about this visual test build.",
})

local about = UI:Section({
	Tab = aboutTab,
	Name = "Clapped Hub UI Lib",
	Description = "A premium Roblox presentation layer.",
})

about:Label({
	Title = "Build",
	Text = "SHOWCASE 01",
})

about:Label({
	Title = "Scope",
	Text = "UI ONLY",
})

UI:Notify({
	Title = "Interface ready",
	Content = "Clapped Hub UI Lib loaded successfully.",
	Icon = "✓",
	Duration = 4,
})
