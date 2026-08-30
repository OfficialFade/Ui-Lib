-- Ocean UI Lib by Fade - notification and loading showcase

local source = game:HttpGet("https://raw.githubusercontent.com/OfficialFade/Ui-Lib/main/ClappedHub.lua?notification_loading=" .. os.clock())
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
	Name = "OCEAN UI LIB",
	Subtitle = "SHOWCASE BY FADE",
	IconImage = "rbxassetid://101595980825854",
	Accent = Color3.fromRGB(80, 175, 255),
	WindowSize = Vector2.new(760, 560),
	ShowSearch = true,
	ShowProfile = true,
	ShowBackground = true,
	EnableDragging = true,
	EnableMinimize = true,
	EnableLoadingMusic = true, -- Optional loading screen/music demonstration.
})

local tab = UI:Tab({
	Name = "Examples",
	Icon = "◆",
	Description = "Notification and loading examples.",
})

local section = UI:Section({
	Tab = tab,
	Name = "Notification showcase",
	Description = "Press the button to display a notification with readable text.",
})

section:Label({
	Title = "Loading screen",
	Text = "ENABLED",
})

local titleBox = section:TextBox({
	Name = "Notification title",
	Description = "Write any title you want to display.",
	Flag = "NotificationTitle",
	Placeholder = "Type a title...",
	Default = "Action complete",
	Width = 175,
})
local messageBox = section:TextBox({
	Name = "Notification message",
	Description = "Write any message or sentence you want.",
	Flag = "NotificationMessage",
	Placeholder = "Type a message...",
	Default = "Executed successfully.",
	Width = 175,
})

section:Button({
	Name = "Send custom notification",
	Text = "EXECUTE",
	Description = "Displays the exact text written in the fields above.",
	Callback = function()
		UI:Notify({
			Title = titleBox.Get(),
			Content = messageBox.Get(),
			Color = Color3.fromRGB(75, 205, 145),
			Icon = "SUCCESS",
			Duration = 4,
		})
	end,
})

section:Button({
	Name = "Error example",
	Text = "ERROR",
	Description = "Shows how an error notification can look.",
	Callback = function()
		UI:Notify({
			Title = "Action failed",
			Content = "Something went wrong. Please try again.",
			Color = Color3.fromRGB(235, 92, 112),
			Icon = "ERROR",
			Duration = 4,
		})
	end,
})

UI:Notify({
	Title = "Loading complete",
	Content = "The interface loaded successfully.",
	Icon = "READY",
	Duration = 4,
})
