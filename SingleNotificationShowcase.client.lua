-- Ocean UI Lib by Fade - single notification showcase
-- One button, no text boxes, and one clear notification message.

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/b3c9c05/ClappedHub.lua?single_notification=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(760, 560),
	WindowMinSize = Vector2.new(500, 420),
	WindowMaxSize = Vector2.new(900, 700),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = true,
})

local tab = UI:Tab({Name = "Example", Icon = "◆", Description = "A simple notification demonstration."})
local section = UI:Section({Tab = tab, Name = "Notification example", Description = "Click the button to display a notification with real text."})
section:Label({Title = "Loading screen", Text = "ENABLED"})
section:Button({
	Name = "Example notification",
	Text = "SEND",
	Description = "Displays: Cipher is a silly goose!",
	Callback = function()
		UI:Notify({
			Title = "Example notification",
			Content = "Cipher is a silly goose!",
			Color = Color3.fromRGB(80, 175, 255),
			Icon = "MESSAGE",
			Duration = 5,
		})
	end,
})
