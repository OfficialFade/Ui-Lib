--!strict
-- Clapped Hub UI Lib
-- Premium, UI-only Roblox interface primitives.
-- This module owns presentation and state only. It does not perform gameplay,
-- automation, exploit, or external action logic.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

Library.Theme = {
	Background = Color3.fromRGB(7, 6, 11),
	Window = Color3.fromRGB(13, 10, 19),
	Sidebar = Color3.fromRGB(10, 8, 15),
	Surface = Color3.fromRGB(21, 15, 28),
	SurfaceRaised = Color3.fromRGB(31, 20, 40),
	SurfaceHover = Color3.fromRGB(45, 24, 48),
	Stroke = Color3.fromRGB(54, 112, 174),
	StrokeSoft = Color3.fromRGB(30, 66, 104),
	Text = Color3.fromRGB(239, 243, 250),
	TextMuted = Color3.fromRGB(151, 161, 180),
	TextFaint = Color3.fromRGB(96, 107, 128),
	Accent = Color3.fromRGB(78, 160, 255),
	AccentBright = Color3.fromRGB(156, 211, 255),
	AccentDeep = Color3.fromRGB(31, 96, 184),
	Success = Color3.fromRGB(74, 205, 143),
	Warning = Color3.fromRGB(245, 183, 73),
	Danger = Color3.fromRGB(235, 92, 112),
}

Library.Flags = {}

local function tween(instance: Instance, duration: number, properties: {[string]: any}, style: Enum.EasingStyle?, direction: Enum.EasingDirection?)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local animation = TweenService:Create(instance, info, properties)
	animation:Play()
	return animation
end

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
	return item
end

local function stroke(parent: Instance, color: Color3, transparency: number, thickness: number?)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Transparency = transparency
	item.Thickness = thickness or 1
	item.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	item.Parent = parent
	return item
end

local function padding(parent: Instance, left: number, right: number, top: number, bottom: number)
	local item = Instance.new("UIPadding")
	item.PaddingLeft = UDim.new(0, left)
	item.PaddingRight = UDim.new(0, right)
	item.PaddingTop = UDim.new(0, top)
	item.PaddingBottom = UDim.new(0, bottom)
	item.Parent = parent
	return item
end

local function text(parent: Instance, value: string, size: number, color: Color3, font: Enum.Font?, transparency: number?)
	local item = Instance.new("TextLabel")
	item.BackgroundTransparency = 1
	item.Text = value
	item.TextColor3 = color
	item.TextSize = size
	item.Font = font or Enum.Font.Gotham
	item.TextTransparency = transparency or 0
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function icon(parent: Instance, glyph: string, size: number, color: Color3)
	local item = text(parent, glyph, size, color, Enum.Font.GothamBold)
	item.TextXAlignment = Enum.TextXAlignment.Center
	item.TextYAlignment = Enum.TextYAlignment.Center
	return item
end

local function normalizeKey(value: any): Enum.KeyCode
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end
	if type(value) == "string" then
		local success, key = pcall(function() return Enum.KeyCode[value] end)
		if success and key then return key end
		local upperSuccess, upperKey = pcall(function() return Enum.KeyCode[string.upper(value)] end)
		if upperSuccess and upperKey then return upperKey end
	end
	return Enum.KeyCode.Unknown
end

local function displayKey(value: Enum.KeyCode): string
	if value == Enum.KeyCode.Unknown then return "NONE" end
	return value.Name
end

local function hover(target: GuiObject, normal: Color3, over: Color3)
	target.MouseEnter:Connect(function() tween(target, 0.18, {BackgroundColor3 = over}) end)
	target.MouseLeave:Connect(function() tween(target, 0.22, {BackgroundColor3 = normal}) end)
end

local function autoCanvas(scroller: ScrollingFrame, layout: UIListLayout)
	local function update()
		scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 28)
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
	update()
end

function Library.new(options: {[string]: any}?)
	options = options or {}
	local self = setmetatable({}, Library)
	self.Name = options.Name or "CLAPPED HUB"
	self.Subtitle = options.Subtitle or "PRIVATE INTERFACE SYSTEM"
	self.Theme = table.clone(Library.Theme)
	self.Flags = {}
	self.Tabs = {}
	self.ActiveTab = nil
	self.Destroyed = false
	self.SearchEntries = {}
	self.KeybindOrder = {}
	self.Keybinds = {}
	self.ActiveKeybindPicker = nil
	self.KeybindPanel = nil
	self.KeybindPanelToggle = nil
	self.CollapsibleSidebar = options.CollapsibleSidebar == true
	self.EnableLoadingMusic = options.EnableLoadingMusic ~= false

	if options.Accent then self.Theme.Accent = options.Accent end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ClappedHubUI"
	gui.DisplayOrder = 100
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self.Gui = gui
	self.KeybindInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if self.Destroyed then return end
		local picking = self.ActiveKeybindPicker
		if picking then
			if input.KeyCode == Enum.KeyCode.Escape then
				if picking.Picker then picking.Picker.Text = picking.DisplayKey end
				self.ActiveKeybindPicker = nil
			elseif input.KeyCode ~= Enum.KeyCode.Unknown then
				picking:SetKey(input.KeyCode)
				self.ActiveKeybindPicker = nil
			end
			return
		end
		if gameProcessed or input.KeyCode == Enum.KeyCode.Unknown then return end
		for _, bind in ipairs(self.KeybindOrder) do
			if bind.Key == input.KeyCode then
				bind:Press()
			end
		end
	end)
	self.KeybindInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if self.Destroyed or input.KeyCode == Enum.KeyCode.Unknown then return end
		for _, bind in ipairs(self.KeybindOrder) do
			if bind.Mode == "Hold" and bind.Key == input.KeyCode then
				bind:SetEnabled(false)
			end
		end
	end)

	local shadow = Instance.new("Frame")
	shadow.Name = "AmbientShadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.fromScale(0.5, 0.5)
	shadow.Size = UDim2.new(0.36, 0, 0.6, 0)
	shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadow.BackgroundTransparency = 0.52
	shadow.BorderSizePixel = 0
	shadow.Parent = gui
	shadow.Visible = false
	corner(shadow, 18)
	local shadowGradient = Instance.new("UIGradient")
	shadowGradient.Color = ColorSequence.new(self.Theme.AccentDeep, Color3.fromRGB(0, 0, 0))
	shadowGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1)})
	shadowGradient.Rotation = 35
	shadowGradient.Parent = shadow

	local window = Instance.new("Frame")
	window.Name = "Window"
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = UDim2.fromScale(0.5, 0.5)
	window.Size = UDim2.new(0.36, 0, 0.6, 0)
	window.BackgroundColor3 = self.Theme.Window
	window.BackgroundTransparency = 1
	window.BorderSizePixel = 0
	window.ClipsDescendants = true
	window.ZIndex = 2
	window.Visible = false
	window.Parent = gui
	corner(window, 20)
	stroke(window, self.Theme.Stroke, 0.24)
	self.Window = window
	local backgroundImage = Instance.new("ImageLabel")
	backgroundImage.Name = "GlassBackdrop"
	backgroundImage.Position = UDim2.fromScale(0, 0)
	backgroundImage.Size = UDim2.fromScale(1, 1)
	backgroundImage.BackgroundTransparency = 1
	backgroundImage.Image = options.BackgroundImage or "rbxassetid://78664802433772"
	backgroundImage.ImageTransparency = options.BackgroundImageTransparency or 0.18
	backgroundImage.ScaleType = Enum.ScaleType.Crop
	backgroundImage.ZIndex = 0
	backgroundImage.Visible = false
	backgroundImage.ClipsDescendants = true
	backgroundImage.Parent = window
	corner(backgroundImage, 20)
	local glassWash = Instance.new("Frame")
	glassWash.Name = "GlassWash"
	glassWash.Position = UDim2.fromScale(0, 0)
	glassWash.Size = UDim2.fromScale(1, 1)
	glassWash.BackgroundColor3 = Color3.fromRGB(9, 18, 34)
	glassWash.BackgroundTransparency = 1
	glassWash.BorderSizePixel = 0
	glassWash.ZIndex = 0
	glassWash.Parent = window
	glassWash.ClipsDescendants = true
	corner(glassWash, 20)
	glassWash.Visible = false
	local washGradient = Instance.new("UIGradient")
	washGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 8, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 7, 19))})
	washGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.14), NumberSequenceKeypoint.new(0.52, 0.34), NumberSequenceKeypoint.new(1, 0.1)})
	washGradient.Rotation = 25
	washGradient.Parent = glassWash
	local windowGradient = Instance.new("UIGradient")
	windowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 29, 41)),
		ColorSequenceKeypoint.new(0.48, self.Theme.Window),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 14, 21)),
	})
	windowGradient.Rotation = 118
	windowGradient.Parent = window

	local topGlow = Instance.new("Frame")
	topGlow.Size = UDim2.new(1, 0, 0, 3)
	topGlow.BackgroundColor3 = self.Theme.AccentBright
	topGlow.BackgroundTransparency = 0.82
	topGlow.BorderSizePixel = 0
	topGlow.ZIndex = 3
	topGlow.Parent = window
	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, self.Theme.AccentDeep), ColorSequenceKeypoint.new(0.52, self.Theme.AccentBright), ColorSequenceKeypoint.new(1, self.Theme.AccentDeep)})
	glowGradient.Parent = topGlow

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 68)
	header.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
	header.BackgroundTransparency = 0.45
	header.BorderSizePixel = 0
	header.ZIndex = 2
	header.ClipsDescendants = true
	header.Parent = window
	corner(header, 20)
	padding(header, 16, 22, 15, 12)

	local brandMark = Instance.new("Frame")
	brandMark.Size = UDim2.fromOffset(36, 36)
	brandMark.BackgroundTransparency = 1
	brandMark.BorderSizePixel = 0
	brandMark.Parent = header
	local logo = Instance.new("ImageLabel")
	logo.Name = "Logo"
	logo.Size = UDim2.fromScale(0.86, 0.86)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.5)
	logo.BackgroundTransparency = 1
	logo.Image = "rbxassetid://101595980825854"
	logo.ScaleType = Enum.ScaleType.Fit
	logo.ZIndex = 2
	logo.Parent = brandMark
	corner(logo, 10)
	stroke(logo, self.Theme.AccentDeep, 0.08, 1.5)

	local brand = Instance.new("Frame")
	brand.BackgroundTransparency = 1
	brand.Position = UDim2.fromOffset(52, 0)
	brand.Size = UDim2.new(0.55, 0, 1, 0)
	brand.Parent = header
	local title = text(brand, self.Name, 16, self.Theme.Text, Enum.Font.GothamBold)
	title.Size = UDim2.new(1, 0, 0, 25)
	local subtitle = text(brand, self.Subtitle, 10, self.Theme.TextMuted, Enum.Font.GothamBold)
	subtitle.Size = UDim2.new(1, 0, 0, 18)
	subtitle.Position = UDim2.fromOffset(0, 27)
	subtitle.TextTransparency = 0.08

	local controls = Instance.new("Frame")
	controls.BackgroundTransparency = 1
	controls.AnchorPoint = Vector2.new(1, 0.5)
	controls.Position = UDim2.new(1, -22, 0.5, 0)
	controls.Size = UDim2.fromOffset(92, 30)
	controls.Parent = header
	local controlLayout = Instance.new("UIListLayout")
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlLayout.Padding = UDim.new(0, 8)
	controlLayout.Parent = controls

	local minimize = Instance.new("TextButton")
	minimize.AutoButtonColor = false
	minimize.Text = "—"
	minimize.TextSize = 18
	minimize.Font = Enum.Font.GothamMedium
	minimize.TextColor3 = self.Theme.Text
	minimize.BackgroundColor3 = self.Theme.StrokeSoft
	minimize.BorderSizePixel = 0
	minimize.Size = UDim2.fromOffset(34, 30)
	minimize.Parent = controls
	corner(minimize, 9)
	hover(minimize, self.Theme.StrokeSoft, self.Theme.AccentDeep)

	local close = minimize:Clone()
	-- Avoid the generic "Close" name: some gamepad binding systems reserve it
	-- for an ImageLabel and will error when they find a TextButton instead.
	close.Name = "DismissControl"
	close.Text = "×"
	close.TextSize = 20
	close.Parent = controls
	close.MouseButton1Click:Connect(function() self:Destroy() end)
	hover(close, self.Theme.StrokeSoft, self.Theme.AccentDeep)

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Position = UDim2.fromOffset(0, 68)
	body.Size = UDim2.new(1, 0, 1, -68)
	body.BackgroundTransparency = 1
	body.ZIndex = 2
	body.ClipsDescendants = true
	body.Parent = window
	corner(body, 20)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 170, 1, 0)
	sidebar.BackgroundColor3 = self.Theme.Sidebar
	sidebar.BackgroundTransparency = 0.55
	sidebar.BorderSizePixel = 0
	sidebar.ClipsDescendants = true
	sidebar.ZIndex = 3
	sidebar.Parent = body
	corner(sidebar, 16)
	padding(sidebar, 8, 8, 14, 14)

	local sidebarGradient = Instance.new("UIGradient")
	sidebarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 27, 39)), ColorSequenceKeypoint.new(1, self.Theme.Sidebar)})
	sidebarGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 0.42)})
	sidebarGradient.Rotation = 90
	sidebarGradient.Parent = sidebar

	local nav = Instance.new("ScrollingFrame")
	nav.Name = "Navigation"
	nav.Size = UDim2.new(1, 0, 1, 0)
	nav.BackgroundTransparency = 1
	nav.BorderSizePixel = 0
	nav.ScrollBarThickness = 2
	nav.ScrollBarImageColor3 = self.Theme.Accent
	nav.CanvasSize = UDim2.new()
	nav.ClipsDescendants = true
	nav.ZIndex = 3
	nav.Parent = sidebar
	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0, 6)
	navLayout.Parent = nav
	autoCanvas(nav, navLayout)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(170, 0)
	content.Size = UDim2.new(1, -170, 1, 0)
	content.ZIndex = 2
	content.BackgroundColor3 = self.Theme.Background
	content.BackgroundTransparency = 0.5
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.Parent = body
	corner(content, 16)
	self.Content = content
	self.Sidebar = sidebar
	self.SidebarNavButtons = {}
	self.SidebarExpanded = true
	local contentGradient = Instance.new("UIGradient")
	contentGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 17, 25)), ColorSequenceKeypoint.new(1, self.Theme.Background)})
	contentGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.02), NumberSequenceKeypoint.new(1, 0.18)})
	contentGradient.Rotation = 25
	contentGradient.Parent = content
	local contentGlow = Instance.new("Frame")
	contentGlow.Name = "AmbientAccent"
	contentGlow.AnchorPoint = Vector2.new(1, 0)
	contentGlow.Position = UDim2.new(1, 80, 0, -80)
	contentGlow.Size = UDim2.fromOffset(360, 360)
	contentGlow.BackgroundColor3 = self.Theme.Accent
	contentGlow.BackgroundTransparency = 1
	contentGlow.BorderSizePixel = 0
	contentGlow.Parent = content
	corner(contentGlow, 360)
	local contentGlowGradient = Instance.new("UIGradient")
	contentGlowGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1)})
	contentGlowGradient.Rotation = 135
	contentGlowGradient.Parent = contentGlow

	local searchBar = Instance.new("Frame")
	searchBar.Name = "SettingsSearch"
	searchBar.Position = UDim2.fromOffset(14, 10)
	searchBar.Size = UDim2.new(1, -28, 0, 32)
	searchBar.BackgroundColor3 = self.Theme.Surface
	searchBar.BackgroundTransparency = 0.28
	searchBar.BorderSizePixel = 0
	searchBar.ZIndex = 5
	searchBar.Parent = content
	corner(searchBar, 9)
	stroke(searchBar, self.Theme.StrokeSoft, 0.42)
	local searchIcon = icon(searchBar, "⌕", 16, self.Theme.AccentBright)
	searchIcon.Position = UDim2.fromOffset(10, 0)
	searchIcon.Size = UDim2.fromOffset(24, 32)
	searchIcon.ZIndex = 6
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Position = UDim2.fromOffset(36, 0)
	searchBox.Size = UDim2.new(1, -46, 1, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.Gotham
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search settings..."
	searchBox.PlaceholderColor3 = self.Theme.TextMuted
	searchBox.TextColor3 = self.Theme.Text
	searchBox.TextSize = 10
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ZIndex = 6
	searchBox.Parent = searchBar
	self.SearchBox = searchBox
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_applySearch(searchBox.Text)
	end)
	self.Nav = nav

	minimize.MouseButton1Click:Connect(function()
		self.Minimized = not self.Minimized
		local nextSize = self.Minimized and UDim2.new(0.36, 0, 0, 64) or UDim2.new(0.36, 0, 0.6, 0)
		tween(window, 0.32, {Size = nextSize})
	end)
	sidebar.MouseEnter:Connect(function() self:_setSidebarExpanded(true) end)
	sidebar.MouseLeave:Connect(function()
		if self.CollapsibleSidebar then self:_setSidebarExpanded(false) end
	end)

	local dragging, dragStart, startPosition
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPosition = window.Position
		end
	end)
	header.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local nextPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
			window.Position = nextPosition
			shadow.Position = nextPosition
		end
	end)

	self:_addResponsiveConstraints(window, content, sidebar)
	self.Window = window
	self.BackgroundImage = backgroundImage
	self.GlassWash = glassWash
	self.AmbientShadow = shadow
	self.WindowRevealed = false
	if self.EnableLoadingMusic then
		task.defer(function()
			self:PlayMusic({
				Url = "https://keyforge.win/lot-of-me.mp3",
				FileName = "lil_tecca_lot_of_me.mp3",
				ShowLoadingScreen = true,
				LoadingTitle = "LOADING",
				LoadingDuration = 11,
				StartTime = 19,
				PlaybackDuration = 11,
				EndTime = 30,
				Volume = 2,
			})
		end)
	else
		self:_revealMainWindow()
	end
	return self
end

function Library:_addResponsiveConstraints(window: Frame, content: Frame, sidebar: Frame)
	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(330, 400)
	sizeConstraint.MaxSize = Vector2.new(520, 620)
	sizeConstraint.Parent = window
	local sidebarConstraint = Instance.new("UISizeConstraint")
	sidebarConstraint.MinSize = Vector2.new(58, 0)
	sidebarConstraint.MaxSize = Vector2.new(184, math.huge)
	sidebarConstraint.Parent = sidebar
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = 1.04
	aspect.DominantAxis = Enum.DominantAxis.Width
	aspect.Parent = window
end

function Library:_setSidebarExpanded(expanded: boolean)
	if self.SidebarExpanded == expanded then return end
	self.SidebarExpanded = expanded
	local width = expanded and 170 or 58
	tween(self.Sidebar, 0.24, {Size = UDim2.new(0, width, 1, 0)})
	tween(self.Content, 0.24, {Position = UDim2.fromOffset(width, 0), Size = UDim2.new(1, -width, 1, 0)})
	for _, item in ipairs(self.SidebarNavButtons) do
		tween(item.Label, 0.18, {TextTransparency = expanded and 0 or 1})
		tween(item.Button, 0.24, {BackgroundTransparency = expanded and 0.42 or 1})
	end
	if self.SidebarStatusLabel then tween(self.SidebarStatusLabel, 0.18, {TextTransparency = expanded and 0.12 or 1}) end
end

function Library:Tab(config: {[string]: any})
	assert(config and config.Name, "Tab requires a Name")
	local tab = {Library = self, Name = config.Name, Icon = config.Icon or "•", Sections = {}}
	tab.Theme = self.Theme
	tab.Flags = self.Flags
	setmetatable(tab, {__index = Library})

	local button = Instance.new("TextButton")
	button.Name = config.Name .. "Nav"
	button.AutoButtonColor = false
	button.Text = ""
	button.Size = UDim2.new(1, 0, 0, 50)
	button.BackgroundColor3 = self.Theme.Sidebar
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.ZIndex = 3
	button.Parent = self.Nav
	corner(button, 9)
	local navGradient = Instance.new("UIGradient")
	navGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, self.Theme.SurfaceRaised), ColorSequenceKeypoint.new(1, self.Theme.Sidebar)})
	navGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.58), NumberSequenceKeypoint.new(1, 0.94)})
	navGradient.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(3, 26)
	indicator.Position = UDim2.fromOffset(0, 12)
	indicator.BackgroundColor3 = self.Theme.AccentDeep
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 4
	indicator.Parent = button
	corner(indicator, 3)
	local glyph = icon(button, tab.Icon, 17, self.Theme.TextMuted)
	glyph.Position = UDim2.fromOffset(10, 0)
	glyph.Size = UDim2.fromOffset(42, 50)
	glyph.ZIndex = 4
	local label = text(button, config.Name, 12, self.Theme.TextMuted, Enum.Font.GothamMedium)
	label.Position = UDim2.fromOffset(48, 0)
	label.Size = UDim2.new(1, -58, 1, 0)
	label.TextTransparency = 1
	label.TextColor3 = self.Theme.Text
	label.ZIndex = 4
	self.SidebarNavButtons = self.SidebarNavButtons or {}
	table.insert(self.SidebarNavButtons, {Button = button, Label = label})
	if self.SidebarExpanded then
		label.TextTransparency = 0
		button.BackgroundTransparency = 0.42
	end

	local page = Instance.new("Frame")
	page.Name = config.Name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = self.Content
	padding(page, 16, 16, 56, 12)

	local pageHeader = text(page, config.Name, 24, self.Theme.Text, Enum.Font.GothamBold)
	pageHeader.Size = UDim2.new(1, 0, 0, 28)
	local pageDescription = text(page, config.Description or "Configure this interface section.", 11, self.Theme.TextMuted, Enum.Font.Gotham)
	pageDescription.Position = UDim2.fromOffset(0, 29)
	pageDescription.Size = UDim2.new(1, 0, 0, 24)

	local scroller = Instance.new("ScrollingFrame")
	scroller.Name = "Scroll"
	scroller.Position = UDim2.fromOffset(0, 58)
	scroller.Size = UDim2.new(1, 0, 1, -58)
	scroller.BackgroundTransparency = 1
	scroller.BorderSizePixel = 0
	scroller.ScrollBarThickness = 3
	scroller.ScrollBarImageColor3 = self.Theme.Accent
	scroller.CanvasSize = UDim2.new()
	scroller.Parent = page
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 9)
	layout.Parent = scroller
	autoCanvas(scroller, layout)
	tab.Page = page
	tab.Layout = layout
	tab.NavButton = button
	tab.NavIndicator = indicator
	tab.NavIcon = glyph
	tab.NavLabel = label
	tab.Scroller = scroller

	button.MouseEnter:Connect(function()
		if self.ActiveTab ~= tab then tween(button, 0.16, {BackgroundColor3 = self.Theme.Surface}) end
	end)
	button.MouseLeave:Connect(function()
		if self.ActiveTab ~= tab then tween(button, 0.2, {BackgroundColor3 = self.Theme.Sidebar}) end
	end)
	button.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
	table.insert(self.Tabs, tab)
	if not self.ActiveTab then self:SelectTab(tab) end
	return tab
end

function Library:SelectTab(tab)
	if self.ActiveTab == tab then return end
	local old = self.ActiveTab
	if old then
		old.Page.Visible = false
		tween(old.NavButton, 0.2, {BackgroundColor3 = self.Theme.Sidebar})
		tween(old.NavIndicator, 0.2, {BackgroundTransparency = 1})
		old.NavLabel.TextColor3 = self.Theme.TextMuted
		old.NavIcon.TextColor3 = self.Theme.TextMuted
	end
	self.ActiveTab = tab
	tab.Page.Visible = true
	tab.Page.Position = UDim2.fromOffset(8, 0)
	tween(tab.Page, 0.28, {Position = UDim2.fromOffset(0, 0)})
	tween(tab.NavButton, 0.24, {BackgroundColor3 = self.Theme.StrokeSoft})
	tween(tab.NavIndicator, 0.24, {BackgroundTransparency = 0})
	tab.NavLabel.TextColor3 = self.Theme.Text
	tab.NavIcon.TextColor3 = self.Theme.AccentBright
end

function Library:Notify(config: {[string]: any})
	config = config or {}
	local holder = self.Gui:FindFirstChild("Notifications") :: Frame
	if not holder then
		holder = Instance.new("Frame")
		holder.Name = "Notifications"
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, -24, 1, -24)
		holder.Size = UDim2.fromOffset(320, 330)
		holder.BackgroundTransparency = 1
		holder.Parent = self.Gui
		local list = Instance.new("UIListLayout")
		list.VerticalAlignment = Enum.VerticalAlignment.Bottom
		list.HorizontalAlignment = Enum.HorizontalAlignment.Right
		list.Padding = UDim.new(0, 9)
		list.Parent = holder
	end

	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(310, 70)
	card.BackgroundColor3 = self.Theme.SurfaceRaised
	card.BorderSizePixel = 0
	card.BackgroundTransparency = 1
	card.ClipsDescendants = true
	card.Parent = holder
	corner(card, 11)
	stroke(card, self.Theme.Stroke, 0.28)
	local notificationBackground = Instance.new("ImageLabel")
	notificationBackground.Name = "NotificationBackground"
	notificationBackground.Size = UDim2.fromScale(1, 1)
	notificationBackground.BackgroundTransparency = 1
	notificationBackground.Image = "rbxassetid://78664802433772"
	notificationBackground.ImageTransparency = 0.52
	notificationBackground.ScaleType = Enum.ScaleType.Crop
	notificationBackground.ZIndex = 0
	notificationBackground.Parent = card
	corner(notificationBackground, 11)
	local notificationWash = Instance.new("Frame")
	notificationWash.Name = "NotificationWash"
	notificationWash.Size = UDim2.fromScale(1, 1)
	notificationWash.BackgroundColor3 = self.Theme.SurfaceRaised
	notificationWash.BackgroundTransparency = 0.58
	notificationWash.BorderSizePixel = 0
	notificationWash.ZIndex = 1
	notificationWash.Parent = card
	corner(notificationWash, 11)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromOffset(3, 40)
	bar.Position = UDim2.fromOffset(12, 15)
	bar.BackgroundColor3 = config.Color or self.Theme.Accent
	bar.BorderSizePixel = 0
	bar.ZIndex = 2
	bar.Parent = card
	corner(bar, 2)
	local glyph = icon(card, config.Icon or "✦", 16, config.Color or self.Theme.AccentBright)
	glyph.Position = UDim2.fromOffset(27, 14)
	glyph.Size = UDim2.fromOffset(28, 24)
	glyph.ZIndex = 3
	local title = text(card, config.Title or "Notification", 11, self.Theme.Text, Enum.Font.GothamBold)
	title.Position = UDim2.fromOffset(61, 10)
	title.Size = UDim2.new(1, -75, 20, 0)
	title.ZIndex = 3
	local message = text(card, config.Content or config.Text or "Notification", 10, self.Theme.TextMuted, Enum.Font.Gotham)
	message.Position = UDim2.fromOffset(61, 30)
	message.Size = UDim2.new(1, -75, 30, 0)
	message.TextWrapped = true
	message.ZIndex = 3
	local function animateNotification(visible: boolean)
		local duration = visible and 0.42 or 0.3
		tween(card, duration, {
			BackgroundTransparency = visible and 0 or 1,
			Position = visible and UDim2.fromOffset(0, 0) or UDim2.fromOffset(18, 0),
		}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
		for _, descendant in ipairs(card:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
				tween(descendant, duration, {TextTransparency = visible and 0 or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			elseif descendant:IsA("ImageLabel") then
				tween(descendant, duration, {ImageTransparency = visible and descendant:GetAttribute("ClappedOriginalTransparency") or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			elseif descendant:IsA("Frame") then
				tween(descendant, duration, {BackgroundTransparency = visible and descendant:GetAttribute("ClappedOriginalTransparency") or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			elseif descendant:IsA("UIStroke") then
				tween(descendant, duration, {Transparency = visible and descendant:GetAttribute("ClappedOriginalTransparency") or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			end
		end
	end
	for _, descendant in ipairs(card:GetDescendants()) do
		if descendant:IsA("ImageLabel") then
			descendant:SetAttribute("ClappedOriginalTransparency", descendant.ImageTransparency)
		elseif descendant:IsA("Frame") then
			descendant:SetAttribute("ClappedOriginalTransparency", descendant.BackgroundTransparency)
		elseif descendant:IsA("UIStroke") then
			descendant:SetAttribute("ClappedOriginalTransparency", descendant.Transparency)
		end
	end
	animateNotification(true)
	task.delay(config.Duration or 4, function()
		if card.Parent then
			animateNotification(false)
			task.wait(0.32)
			card:Destroy()
		end
	end)
	return card
end

function Library:_revealMainWindow()
	if self.WindowRevealed or self.Destroyed then return end
	self.WindowRevealed = true
	self.Window.Visible = true
	self.BackgroundImage.Visible = true
	self.GlassWash.Visible = true
	-- The shadow uses a different aspect ratio than the responsive window and
	-- can spill below it. Keep the panel edge clean at every size.
	self.AmbientShadow.Visible = false
	-- Keep the frame itself transparent so the 78664802433772 backdrop can
	-- show through the glass surfaces and content cards.
	self.Window.BackgroundTransparency = 1

	local windowScale = Instance.new("UIScale")
	windowScale.Scale = 0.16
	windowScale.Parent = self.Window
	tween(windowScale, 0.78, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tween(self.BackgroundImage, 0.64, {ImageTransparency = 0.18})
	tween(self.GlassWash, 0.64, {BackgroundTransparency = 0.3})
	tween(self.AmbientShadow, 0.5, {BackgroundTransparency = 0.52})
	-- Keep user-created tabs visible and easy to navigate after initialization.
	self:_setSidebarExpanded(true)
end

-- Downloads and plays the built-in client-side audio segment during loading.
function Library:PlayMusic(config: {[string]: any})
	config = config or {}
	local audioUrl = config.Url
	local fileName = config.FileName or "downloaded_audio.mp3"
	local loadingDuration = config.LoadingDuration or 10
	local playbackDuration = config.PlaybackDuration or 10
	local startTime = config.StartTime or 0
	local endTime = config.EndTime or (startTime + playbackDuration)

	assert(type(audioUrl) == "string" and audioUrl ~= "", "PlayMusic requires a Url")

	if self.MusicSound then
		self.MusicSound:Stop()
		self.MusicSound:Destroy()
		self.MusicSound = nil
	end
	if self.LoadingOverlay then
		self.LoadingOverlay:Destroy()
		self.LoadingOverlay = nil
	end

	local generation = (self.MusicGeneration or 0) + 1
	self.MusicGeneration = generation
	local startedAt = os.clock()
	local overlay
	local loadingSubtitle

	if config.ShowLoadingScreen then
		overlay = Instance.new("Frame")
		overlay.Name = "MusicLoadingScreen"
		overlay.Size = UDim2.fromScale(1, 1)
		overlay.BackgroundColor3 = self.Theme.Background
		overlay.BackgroundTransparency = 0.04
		overlay.BorderSizePixel = 0
		overlay.ZIndex = 100
		overlay.Parent = self.Gui
		self.LoadingOverlay = overlay

		local panel = Instance.new("Frame")
		panel.Name = "LoadingPanel"
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.Size = UDim2.fromOffset(304, 58)
		panel.BackgroundColor3 = self.Theme.SurfaceRaised
		panel.BackgroundTransparency = 0.08
		panel.BorderSizePixel = 0
		panel.ZIndex = 101
		panel.ClipsDescendants = true
		panel.Parent = overlay
		corner(panel, 12)
		stroke(panel, self.Theme.Stroke, 0.28)
		local loadingBackground = Instance.new("ImageLabel")
		loadingBackground.Name = "LoadingBackground"
		loadingBackground.Size = UDim2.fromScale(1, 1)
		loadingBackground.BackgroundTransparency = 1
		loadingBackground.Image = "rbxassetid://78664802433772"
		loadingBackground.ImageTransparency = 0.5
		loadingBackground.ScaleType = Enum.ScaleType.Crop
		loadingBackground.ZIndex = 101
		loadingBackground.Parent = panel
		corner(loadingBackground, 12)
		local loadingWash = Instance.new("Frame")
		loadingWash.Size = UDim2.fromScale(1, 1)
		loadingWash.BackgroundColor3 = self.Theme.Window
		loadingWash.BackgroundTransparency = 0.16
		loadingWash.BorderSizePixel = 0
		loadingWash.ZIndex = 102
		loadingWash.Parent = panel
		corner(loadingWash, 12)
		local accentLine = Instance.new("Frame")
		accentLine.Size = UDim2.new(0, 4, 1, -20)
		accentLine.Position = UDim2.fromOffset(12, 10)
		accentLine.BackgroundColor3 = self.Theme.AccentBright
		accentLine.BorderSizePixel = 0
		accentLine.ZIndex = 103
		accentLine.Parent = panel
		corner(accentLine, 2)

		local loadingTitle = text(panel, config.LoadingTitle or "LOADING", 15, self.Theme.Text, Enum.Font.GothamBold)
		loadingTitle.ZIndex = 104
		loadingTitle.AnchorPoint = Vector2.new(0.5, 0.5)
		loadingTitle.Position = UDim2.fromScale(0.52, 0.36)
		loadingTitle.Size = UDim2.fromOffset(250, 22)
		loadingTitle.TextXAlignment = Enum.TextXAlignment.Center
		loadingSubtitle = text(panel, "Please wait...", 9, self.Theme.TextMuted, Enum.Font.Gotham)
		loadingSubtitle.ZIndex = 104
		loadingSubtitle.AnchorPoint = Vector2.new(0.5, 0.5)
		loadingSubtitle.Position = UDim2.fromScale(0.52, 0.68)
		loadingSubtitle.Size = UDim2.fromOffset(250, 18)
		loadingSubtitle.TextXAlignment = Enum.TextXAlignment.Center
	end

	local function setLoadingStatus(status: string)
		if loadingSubtitle then loadingSubtitle.Text = status end
		if config.OnStatus then config.OnStatus(status) end
	end

	local function closeLoadingScreen()
		if overlay and overlay.Parent then overlay:Destroy() end
		if self.LoadingOverlay == overlay then self.LoadingOverlay = nil end
		if config.ShowLoadingScreen then self:_revealMainWindow() end
	end

	local function failLoading(message: string)
		setLoadingStatus(message)
		if config.OnError then config.OnError(message) end
		-- Keep the loading transition visible instead of destroying it instantly
		-- when local-audio support is unavailable or the download fails.
		task.delay(loadingDuration, function()
			if generation == self.MusicGeneration then closeLoadingScreen() end
		end)
		return false
	end

	setLoadingStatus("Initializing...")
	print("Downloading audio file...")
	local success, fileData = pcall(function()
		return game:HttpGet(audioUrl)
	end)

	if self.Destroyed or generation ~= self.MusicGeneration then
		closeLoadingScreen()
		return false
	end
	if not success or not fileData or #fileData == 0 then
		return failLoading("Failed to download audio. Check if the URL has expired.")
	end

	print("Download finished. Preparing playback...")
	local saved, saveError = pcall(function()
		writefile(fileName, fileData)
	end)
	if not saved then
		warn(saveError)
		return failLoading("Failed to save the downloaded audio file")
	end

	if not (getcustomasset or Content and Content.Source) then
		return failLoading("Your executor does not support getcustomasset")
	end
	local getasset = getcustomasset or Content.Source
	local assetSuccess, assetId = pcall(function()
		return getasset(fileName)
	end)
	if not assetSuccess or not assetId then
		return failLoading("Failed to create a local audio asset")
	end

	local sound = Instance.new("Sound")
	sound.Name = config.Name or "CustomAudioPlayer"
	sound.Volume = config.Volume or 2
	sound.Parent = workspace
	self.MusicSound = sound
	sound.SoundId = assetId
	if not sound.IsLoaded then sound.Loaded:Wait() end
	if sound.Parent and generation == self.MusicGeneration then
		sound.TimePosition = startTime
		sound:Play()
	end
	setLoadingStatus("Initializing...")

	-- Keep the loading screen visible while the selected audio segment plays.
	local remainingLoading = math.max(loadingDuration - (os.clock() - startedAt), playbackDuration)
	if remainingLoading > 0 then
		task.delay(remainingLoading, closeLoadingScreen)
	else
		closeLoadingScreen()
	end

	task.spawn(function()
		while sound.Playing and generation == self.MusicGeneration do
			if sound.TimePosition >= endTime then
				sound:Stop()
				if sound.Parent then sound:Destroy() end
				if self.MusicSound == sound then self.MusicSound = nil end
				closeLoadingScreen()
				if config.OnStatus then config.OnStatus("Audio stopped") end
				break
			end
			task.wait(0.1)
		end
	end)
	return true
end

function Library:Destroy()
	if self.Destroyed then return end
	self.Destroyed = true
	self.MusicGeneration = (self.MusicGeneration or 0) + 1
	if self.KeybindInputConnection then
		self.KeybindInputConnection:Disconnect()
		self.KeybindInputConnection = nil
	end
	if self.KeybindInputEndedConnection then
		self.KeybindInputEndedConnection:Disconnect()
		self.KeybindInputEndedConnection = nil
	end
	if self.KeybindPanelDragConnection then
		self.KeybindPanelDragConnection:Disconnect()
		self.KeybindPanelDragConnection = nil
	end
	if self.KeybindPanelInputEndedConnection then
		self.KeybindPanelInputEndedConnection:Disconnect()
		self.KeybindPanelInputEndedConnection = nil
	end
	if self.MusicSound then
		self.MusicSound:Stop()
		self.MusicSound:Destroy()
		self.MusicSound = nil
	end
	if self.LoadingOverlay then
		self.LoadingOverlay:Destroy()
		self.LoadingOverlay = nil
	end
	if self.Gui then self.Gui:Destroy() end
end

function Library:_applySearch(queryValue: string)
	local query = string.lower(queryValue or "")
	local firstMatchTab = nil
	local sectionMatches = {}
	for _, entry in ipairs(self.SearchEntries) do
		local matches = query == "" or string.find(entry.SearchText, query, 1, true) ~= nil
		entry.Row.Visible = matches
		if matches then
			firstMatchTab = firstMatchTab or entry.Tab
		end
		sectionMatches[entry.Section] = sectionMatches[entry.Section] or false
		if matches then sectionMatches[entry.Section] = true end
	end
	for section, matches in pairs(sectionMatches) do
		section.Visible = matches or query == ""
	end
	if query ~= "" and firstMatchTab and self.ActiveTab ~= firstMatchTab then
		self:SelectTab(firstMatchTab)
	end
end

function Library:_controlRow(parent: Instance, titleValue: string, descriptionValue: string?)
	local library = self.Library or self
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, descriptionValue and 55 or 44)
	row.BackgroundColor3 = self.Theme.Surface
	row.BackgroundTransparency = 0.62
	row.BorderSizePixel = 0
	row.Parent = parent
	corner(row, 6)
	stroke(row, self.Theme.StrokeSoft, 0.72)
	hover(row, self.Theme.Surface, self.Theme.SurfaceHover)
	local titleLabel = text(row, titleValue, 11, self.Theme.Text, Enum.Font.GothamMedium)
	titleLabel.Position = UDim2.fromOffset(16, descriptionValue and 11 or 0)
	titleLabel.Size = UDim2.new(0.55, 0, 0, 20)
	if descriptionValue then
		local descriptionLabel = text(row, descriptionValue, 9, self.Theme.TextMuted, Enum.Font.Gotham)
		descriptionLabel.Position = UDim2.fromOffset(16, 31)
		descriptionLabel.Size = UDim2.new(0.58, 0, 0, 18)
		descriptionLabel.TextTransparency = 0.08
	end
	library.SearchEntries = library.SearchEntries or {}
	table.insert(library.SearchEntries, {
		Row = row,
		Section = self.Root,
		Tab = self.Tab,
		SearchText = string.lower(titleValue .. " " .. (descriptionValue or "")),
	})
	if self.Rows then table.insert(self.Rows, row) end
	return row
end

function Library:Section(config: {[string]: any})
	assert(config and config.Tab and config.Name, "Section requires Tab and Name")
	local section = {Library = self, Tab = config.Tab, Name = config.Name, Rows = {}}
	section.Theme = self.Theme
	section.Flags = self.Flags
	setmetatable(section, {__index = Library})
	local card = Instance.new("Frame")
	card.Name = config.Name .. "Section"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = self.Theme.Surface
	card.BackgroundTransparency = 0.6
	card.BorderSizePixel = 0
	card.Parent = config.Tab.Scroller
	corner(card, 3)
	stroke(card, self.Theme.Stroke, 0.78)
	padding(card, 14, 14, 14, 14)
	section.Root = card
	local cardGradient = Instance.new("UIGradient")
	cardGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, self.Theme.SurfaceRaised), ColorSequenceKeypoint.new(1, self.Theme.Surface)})
	cardGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0.52)})
	cardGradient.Rotation = 105
	cardGradient.Parent = card
	local heading = text(card, config.Name, 12, self.Theme.Text, Enum.Font.GothamBold)
	heading.Size = UDim2.new(1, 0, 0, 22)
	local caption = text(card, config.Description or "", 9, self.Theme.TextMuted, Enum.Font.Gotham)
	caption.Position = UDim2.fromOffset(0, 23)
	caption.Size = UDim2.new(1, 0, 0, config.Description and 18 or 0)
	caption.Visible = config.Description ~= nil
	local controls = Instance.new("Frame")
	controls.Position = UDim2.fromOffset(0, config.Description and 50 or 34)
	controls.Size = UDim2.new(1, 0, 0, 0)
	controls.AutomaticSize = Enum.AutomaticSize.Y
	controls.BackgroundTransparency = 1
	controls.Parent = card
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.Parent = controls
	section.Container = controls
	return section
end

function Library:Label(config: {[string]: any})
	local row = self:_controlRow(self.Container, config.Title or config.Text or "", config.Description)
	local body = text(row, config.Text or "", 10, self.Theme.TextMuted, Enum.Font.Gotham)
	body.Position = UDim2.new(0.58, 0, 0, 0)
	body.Size = UDim2.new(0.42, -12, 1, 0)
	body.TextXAlignment = Enum.TextXAlignment.Right
	body.TextWrapped = true
	return row
end

function Library:Button(config: {[string]: any})
	local row = self:_controlRow(self.Container, config.Name or "Action", config.Description)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Text = config.Text or "EXECUTE"
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = self.Theme.Text
	button.BackgroundColor3 = self.Theme.AccentDeep
	button.BackgroundTransparency = 0.18
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.Size = UDim2.fromOffset(112, 31)
	button.Parent = row
	corner(button, 8)
	hover(button, self.Theme.AccentDeep, self.Theme.Accent)
	local enabled = true
	local function setEnabled(nextEnabled: boolean)
		enabled = nextEnabled
		button.Active = enabled
		button.TextTransparency = enabled and 0 or 0.55
		button.BackgroundTransparency = enabled and 0.18 or 0.62
	end
	button.MouseButton1Click:Connect(function()
		if not enabled or not config.Callback then return end
		local success, errorMessage = pcall(config.Callback)
		if not success then warn("ClappedHub button callback failed:", errorMessage) end
	end)
	return {
		Row = row,
		Button = button,
		SetEnabled = setEnabled,
		SetText = function(value: string) button.Text = value end,
	}
end

function Library:Toggle(config: {[string]: any})
	local value = config.Default == true
	local row = self:_controlRow(self.Container, config.Name or "Toggle", config.Description)
	local toggle = Instance.new("TextButton")
	toggle.AutoButtonColor = false
	toggle.Text = ""
	toggle.AnchorPoint = Vector2.new(1, 0.5)
	toggle.Position = UDim2.new(1, -16, 0.5, 0)
	toggle.Size = UDim2.fromOffset(42, 23)
	toggle.BackgroundColor3 = Color3.fromRGB(8, 13, 23)
	toggle.BackgroundTransparency = 0.28
	toggle.BorderSizePixel = 0
	toggle.Parent = row
	corner(toggle, 13)
	stroke(toggle, self.Theme.Stroke, 0.18)
	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(17, 17)
	knob.Position = UDim2.fromOffset(3, 3)
	knob.BackgroundColor3 = self.Theme.Text
	knob.BorderSizePixel = 0
	knob.Parent = toggle
	corner(knob, 9)
	local function set(nextValue: boolean, silent: boolean?)
		value = nextValue
		self.Flags[config.Flag or config.Name or "Toggle"] = value
		tween(toggle, 0.2, {
			BackgroundColor3 = value and self.Theme.AccentDeep or Color3.fromRGB(8, 13, 23),
			BackgroundTransparency = value and 0.12 or 0.28,
		})
		tween(knob, 0.24, {Position = value and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = self.Theme.Text})
		if not silent and config.Callback then
			local success, errorMessage = pcall(config.Callback, value)
			if not success then warn("ClappedHub toggle callback failed:", errorMessage) end
		end
	end
	toggle.MouseButton1Click:Connect(function() set(not value) end)
	set(value, true)
	return {Row = row, Toggle = toggle, Set = set, Get = function() return value end}
end

function Library:Keybind(config: {[string]: any})
	assert(config and config.Name, "Keybind requires a Name")
	local library = self.Library or self
	local row = self:_controlRow(self.Container, config.Name, config.Description)
	local key = normalizeKey(config.Key or config.DefaultKey)
	local identifier = config.Flag or config.Name
	local bind = {
		Library = library,
		Name = config.Name,
		Key = key,
		DisplayKey = displayKey(key),
		Mode = config.Mode == "Hold" and "Hold" or "Toggle",
		Enabled = config.DefaultEnabled == true,
		Flag = identifier,
		Callback = config.Callback,
	}

	local picker = Instance.new("TextButton")
	picker.Name = "KeyPicker"
	picker.AutoButtonColor = false
	picker.Text = bind.DisplayKey
	picker.TextSize = 10
	picker.Font = Enum.Font.GothamBold
	picker.TextColor3 = library.Theme.Text
	picker.BackgroundColor3 = library.Theme.StrokeSoft
	picker.BackgroundTransparency = 0.12
	picker.BorderSizePixel = 0
	picker.AnchorPoint = Vector2.new(1, 0.5)
	picker.Position = UDim2.new(1, -14, 0.5, 0)
	picker.Size = UDim2.fromOffset(78, 29)
	picker.Parent = row
	corner(picker, 8)
	stroke(picker, library.Theme.AccentDeep, 0.25)
	hover(picker, library.Theme.StrokeSoft, library.Theme.AccentDeep)
	bind.Picker = picker

	function bind:SetKey(nextKey: any)
		self.Key = normalizeKey(nextKey)
		self.DisplayKey = displayKey(self.Key)
		self.Picker.Text = self.DisplayKey
		if self.PanelKeyLabel then self.PanelKeyLabel.Text = self.DisplayKey end
	end

	function bind:SetEnabled(nextEnabled: boolean, silent: boolean?)
		self.Enabled = nextEnabled == true
		self.Library.Flags[self.Flag] = self.Enabled
		if self.PanelRow then
			tween(self.PanelRow, 0.2, {
				BackgroundColor3 = self.Enabled and self.Library.Theme.AccentDeep or self.Library.Theme.Surface,
				BackgroundTransparency = self.Enabled and 0.16 or 0.48,
			})
		end
		if self.PanelKeyLabel then
			self.PanelKeyLabel.TextColor3 = self.Enabled and self.Library.Theme.Text or self.Library.Theme.AccentBright
		end
		if not silent and self.Callback then
			local success, errorMessage = pcall(self.Callback, self.Enabled)
			if not success then warn("ClappedHub keybind callback failed:", errorMessage) end
		end
	end

	function bind:Press()
		if self.Mode == "Hold" then
			self:SetEnabled(true)
		else
			self:SetEnabled(not self.Enabled)
		end
	end

	picker.MouseButton1Click:Connect(function()
		if library.ActiveKeybindPicker and library.ActiveKeybindPicker.Picker then
			library.ActiveKeybindPicker.Picker.Text = library.ActiveKeybindPicker.DisplayKey
		end
		library.ActiveKeybindPicker = bind
		picker.Text = "PRESS KEY"
	end)

	library.Keybinds[identifier] = bind
	table.insert(library.KeybindOrder, bind)
	bind:SetEnabled(bind.Enabled, true)
	if library.KeybindPanel then library:_refreshKeybindPanel() end
	return bind
end

function Library:KeybindListToggle(config: {[string]: any})
	config = config or {}
	local library = self.Library or self
	local callback = config.Callback
	local toggleConfig = table.clone(config)
	toggleConfig.Name = config.Name or "Show keybinds"
	toggleConfig.Description = config.Description or "Open the active keybind list."
	toggleConfig.Default = config.Default == true
	toggleConfig.Callback = function(enabled: boolean)
		library:SetKeybindPanelVisible(enabled)
		if callback then
			local success, errorMessage = pcall(callback, enabled)
			if not success then warn("ClappedHub keybind panel callback failed:", errorMessage) end
		end
	end
	local control = self:Toggle(toggleConfig)
	library.KeybindPanelToggle = control
	if toggleConfig.Default then library:SetKeybindPanelVisible(true) end
	return control
end

function Library:_refreshKeybindPanel()
	if not self.KeybindPanel or not self.KeybindList then return end
	for _, bind in ipairs(self.KeybindOrder) do
		bind.PanelRow = nil
		bind.PanelKeyLabel = nil
	end
	for _, child in ipairs(self.KeybindList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local hasKeybinds = #self.KeybindOrder > 0
	if self.KeybindEmpty then self.KeybindEmpty.Visible = not hasKeybinds end
	for _, bind in ipairs(self.KeybindOrder) do
		local row = Instance.new("Frame")
		row.Name = bind.Name .. "Keybind"
		row.Size = UDim2.new(1, 0, 0, 38)
		row.BackgroundColor3 = bind.Enabled and self.Theme.AccentDeep or self.Theme.Surface
		row.BackgroundTransparency = bind.Enabled and 0.16 or 0.48
		row.BorderSizePixel = 0
		row.Parent = self.KeybindList
		corner(row, 8)
		stroke(row, bind.Enabled and self.Theme.Accent or self.Theme.StrokeSoft, bind.Enabled and 0.22 or 0.5)
		local title = text(row, bind.Name, 10, self.Theme.Text, Enum.Font.GothamMedium)
		title.Position = UDim2.fromOffset(12, 0)
		title.Size = UDim2.new(1, -92, 1, 0)
		title.ZIndex = 23
		local keyLabel = text(row, bind.DisplayKey, 10, bind.Enabled and self.Theme.Text or self.Theme.AccentBright, Enum.Font.GothamBold)
		keyLabel.Position = UDim2.new(1, -80, 0, 0)
		keyLabel.Size = UDim2.fromOffset(68, 38)
		keyLabel.TextXAlignment = Enum.TextXAlignment.Right
		keyLabel.ZIndex = 23
		bind.PanelRow = row
		bind.PanelKeyLabel = keyLabel
	end
end

function Library:_ensureKeybindPanel()
	if self.KeybindPanel then return end
	local panel = Instance.new("Frame")
	panel.Name = "KeybindPanel"
	panel.AnchorPoint = Vector2.new(1, 1)
	panel.Position = UDim2.new(1, -24, 1, -24)
	panel.Size = UDim2.fromOffset(286, 260)
	panel.BackgroundColor3 = self.Theme.Window
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.ClipsDescendants = true
	panel.ZIndex = 20
	panel.Parent = self.Gui
	corner(panel, 17)
	stroke(panel, self.Theme.Stroke, 0.24)
	local background = Instance.new("ImageLabel")
	background.Name = "KeybindBackground"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1
	background.Image = self.BackgroundImage.Image
	background.ImageTransparency = 0.18
	background.ScaleType = Enum.ScaleType.Crop
	background.ZIndex = 20
	background.Parent = panel
	corner(background, 17)
	local wash = Instance.new("Frame")
	wash.Name = "KeybindWash"
	wash.Size = UDim2.fromScale(1, 1)
	wash.BackgroundColor3 = Color3.fromRGB(8, 16, 30)
	wash.BackgroundTransparency = 0.3
	wash.BorderSizePixel = 0
	wash.ZIndex = 20
	wash.Parent = panel
	corner(wash, 17)
	local header = Instance.new("Frame")
	header.Name = "KeybindHeader"
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
	header.BackgroundTransparency = 0.34
	header.BorderSizePixel = 0
	header.ZIndex = 21
	header.Parent = panel
	local title = text(header, "KEYBINDS", 13, self.Theme.Text, Enum.Font.GothamBold)
	title.Position = UDim2.fromOffset(16, 4)
	title.Size = UDim2.new(1, -62, 0, 23)
	title.ZIndex = 22
	local subtitle = text(header, "ACTIVE CONTROLS", 8, self.Theme.TextMuted, Enum.Font.GothamBold)
	subtitle.Position = UDim2.fromOffset(16, 27)
	subtitle.Size = UDim2.new(1, -62, 0, 16)
	subtitle.ZIndex = 22
	local close = Instance.new("TextButton")
	close.Name = "CloseKeybinds"
	close.AutoButtonColor = false
	close.Text = "×"
	close.TextSize = 17
	close.Font = Enum.Font.GothamMedium
	close.TextColor3 = self.Theme.Text
	close.BackgroundColor3 = self.Theme.StrokeSoft
	close.BackgroundTransparency = 0.16
	close.BorderSizePixel = 0
	close.AnchorPoint = Vector2.new(1, 0.5)
	close.Position = UDim2.new(1, -14, 0.5, 0)
	close.Size = UDim2.fromOffset(30, 27)
	close.ZIndex = 22
	close.Parent = header
	corner(close, 8)
	hover(close, self.Theme.StrokeSoft, self.Theme.AccentDeep)
	local list = Instance.new("ScrollingFrame")
	list.Name = "KeybindList"
	list.Position = UDim2.fromOffset(12, 64)
	list.Size = UDim2.new(1, -24, 1, -76)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 2
	list.ScrollBarImageColor3 = self.Theme.Accent
	list.CanvasSize = UDim2.new()
	list.ZIndex = 21
	list.Parent = panel
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6)
	layout.Parent = list
	autoCanvas(list, layout)
	local empty = text(panel, "No keybinds added.", 10, self.Theme.TextMuted, Enum.Font.Gotham)
	empty.Position = UDim2.fromOffset(20, 124)
	empty.Size = UDim2.new(1, -40, 0, 24)
	empty.TextXAlignment = Enum.TextXAlignment.Center
	empty.ZIndex = 22
	self.KeybindPanel = panel
	self.KeybindList = list
	self.KeybindEmpty = empty
	self:_refreshKeybindPanel()

	local dragging = false
	local dragStart
	local startPosition
	local dragInput
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = panel.Position
		end
	end)
	header.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
	end)
	self.KeybindPanelDragConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			local delta = input.Position - dragStart
			panel.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
	self.KeybindPanelInputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	close.MouseButton1Click:Connect(function()
		self:SetKeybindPanelVisible(false)
		if self.KeybindPanelToggle then self.KeybindPanelToggle.Set(false, true) end
	end)
end

function Library:SetKeybindPanelVisible(visible: boolean)
	self:_ensureKeybindPanel()
	self.KeybindPanel.Visible = visible == true
	if visible then self:_refreshKeybindPanel() end
end

function Library:Slider(config: {[string]: any})
	local minimum, maximum = config.Min or 0, config.Max or 100
	local value = math.clamp(config.Default or minimum, minimum, maximum)
	local row = self:_controlRow(self.Container, config.Name or "Slider", config.Description)
	row.Size = UDim2.new(1, 0, 0, config.Description and 72 or 62)
	local valueLabel = text(row, "", 10, self.Theme.AccentBright, Enum.Font.GothamBold)
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -16, 0, 12)
	valueLabel.Size = UDim2.fromOffset(72, 20)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local track = Instance.new("Frame")
	track.Position = UDim2.new(0, 16, 1, -24)
	track.Size = UDim2.new(1, -48, 0, 6)
	track.BackgroundColor3 = self.Theme.StrokeSoft
	track.BackgroundTransparency = 0.18
	track.BorderSizePixel = 0
	track.Parent = row
	corner(track, 5)
	stroke(track, self.Theme.AccentDeep, 0.35, 1)
	local fill = track:Clone()
	fill.Name = "Fill"
	fill.Position = UDim2.fromScale(0, 0)
	fill.AnchorPoint = Vector2.new(0, 0)
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = self.Theme.Accent
	fill.BackgroundTransparency = 0.02
	fill.Parent = track
	local dot = Instance.new("Frame")
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Size = UDim2.fromOffset(13, 13)
	dot.Position = UDim2.new(1, 0, 0.5, 0)
	dot.BackgroundColor3 = self.Theme.Text
	dot.BorderSizePixel = 0
	dot.Parent = fill
	corner(dot, 7)
	local hit = Instance.new("TextButton")
	hit.Text = ""
	hit.BackgroundTransparency = 1
	hit.Size = UDim2.new(1, 0, 0, 22)
	hit.Position = UDim2.new(0, 0, 0.5, -11)
	hit.Parent = track
	local draggingSlider = false
	local function set(nextValue: number, silent: boolean?)
		value = math.clamp(nextValue, minimum, maximum)
		local percent = (value - minimum) / (maximum - minimum)
		valueLabel.Text = string.format(config.Format or "%d", value)
		self.Flags[config.Flag or config.Name or "Slider"] = value
		tween(fill, 0.16, {Size = UDim2.fromScale(percent, 1)})
		if not silent and config.Callback then
			local success, errorMessage = pcall(config.Callback, value)
			if not success then warn("ClappedHub slider callback failed:", errorMessage) end
		end
	end
	local function update(input: InputObject)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		set(minimum + ((maximum - minimum) * percent))
	end
	hit.MouseButton1Down:Connect(function()
		draggingSlider = true
		update({Position = UserInputService:GetMouseLocation()} :: any)
	end)
	hit.MouseButton1Click:Connect(function() update({Position = UserInputService:GetMouseLocation()} :: any) end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
	end)
	set(value, true)
	return {Row = row, Track = track, Set = set, Get = function() return value end}
end

return Library
