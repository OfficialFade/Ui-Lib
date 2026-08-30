-- Ocean UI Lib by Fade - focused product showcase
-- A minimal buyer demo showing only buttons and sliders.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?button_slider_showcase=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(780, 560),
	WindowMinSize = Vector2.new(500, 420),
	WindowMaxSize = Vector2.new(1000, 760),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = false,
})

local function notify(title, content)
	UI:Notify({Title = title, Content = content, Color = Color3.fromRGB(80, 175, 255), Icon = "✓", Duration = 3})
end

local buttonsTab = UI:Tab({Name = "Buttons", Icon = "◆", Description = "Clean buttons and smooth sliders."})
local buttons = UI:Section({Tab = buttonsTab, Name = "Button showcase", Description = "A focused preview of the core components used in a finished script."})
buttons:Button({Name = "Primary button", Text = "CLICK", Description = "Light-blue button styling with hover feedback.", Callback = function()
	notify("Button clicked", "The callback executed successfully.")
end})
buttons:Button({Name = "Secondary button", Text = "PREVIEW", Width = 135, Description = "Multiple actions can be added to one section.", Callback = function()
	notify("Preview ready", "Your next feature can use the same button component.")
end})
buttons:Slider({Name = "Amount slider", Description = "Smooth numeric input with custom formatting.", Flag = "Amount", Min = 0, Max = 100, Default = 70, Format = "%d%%", Callback = function(value)
	print("Amount:", value)
end})
buttons:Slider({Name = "Speed slider", Description = "A second slider for independent values.", Flag = "Speed", Min = 1, Max = 10, Default = 5, Format = "%d", Callback = function(value)
	print("Speed:", value)
end})
buttons:Label({Title = "Component status", Text = "READY FOR PRODUCTION"})

UI:Notify({Title = "Showcase ready", Content = "Preview the buttons and sliders in Ocean UI Lib by Fade.", Icon = "✓", Duration = 5})
