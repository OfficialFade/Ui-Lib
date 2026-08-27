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

	if options.Accent then self.Theme.Accent = options.Accent end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ClappedHubUI"
	gui.DisplayOrder = 100
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self.Gui = gui

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
	corner(window, 16)
	stroke(window, self.Theme.Stroke, 1)
	self.Window = window
	local backgroundImage = Instance.new("ImageLabel")
	backgroundImage.Name = "GlassBackdrop"
	backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
	backgroundImage.Position = window.Position
	backgroundImage.Size = window.Size
	backgroundImage.BackgroundTransparency = 1
	backgroundImage.Image = options.BackgroundImage or "rbxassetid://78664802433772"
	backgroundImage.ImageTransparency = options.BackgroundImageTransparency or 0.52
	backgroundImage.ScaleType = Enum.ScaleType.Crop
	backgroundImage.ZIndex = 0
	backgroundImage.Visible = false
	backgroundImage.Parent = gui
	corner(backgroundImage, 16)
	stroke(backgroundImage, self.Theme.Stroke, 0.18)
	local glassWash = Instance.new("Frame")
	glassWash.Name = "GlassWash"
	glassWash.AnchorPoint = Vector2.new(0.5, 0.5)
	glassWash.Position = window.Position
	glassWash.Size = window.Size
	glassWash.BackgroundColor3 = Color3.fromRGB(8, 7, 15)
	glassWash.BackgroundTransparency = 1
	glassWash.BorderSizePixel = 0
	glassWash.ZIndex = 0
	glassWash.Parent = gui
	corner(glassWash, 16)
	glassWash.Visible = false
	local function syncBackdrop()
		local size = window.AbsoluteSize
		local position = window.AbsolutePosition + (size / 2)
		backgroundImage.Position = UDim2.fromOffset(position.X, position.Y)
		backgroundImage.Size = UDim2.fromOffset(size.X, size.Y)
		glassWash.Position = UDim2.fromOffset(position.X, position.Y)
		glassWash.Size = UDim2.fromOffset(size.X, size.Y)
	end
	window:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncBackdrop)
	window:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncBackdrop)
	task.defer(syncBackdrop)
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
	header.BackgroundTransparency = 0.1
	header.BorderSizePixel = 0
	header.ZIndex = 2
	header.Parent = window
	padding(header, 28, 22, 15, 12)

	local brandMark = Instance.new("Frame")
	brandMark.Size = UDim2.fromOffset(36, 36)
	brandMark.BackgroundColor3 = self.Theme.AccentDeep
	brandMark.BorderSizePixel = 0
	brandMark.Parent = header
	corner(brandMark, 11)
	local mark = icon(brandMark, "✦", 20, self.Theme.Text)
	mark.Size = UDim2.fromScale(1, 1)
	local markGradient = Instance.new("UIGradient")
	markGradient.Color = ColorSequence.new(self.Theme.AccentBright, self.Theme.Text)
	markGradient.Rotation = 90
	markGradient.Parent = mark

	local brand = Instance.new("Frame")
	brand.BackgroundTransparency = 1
	brand.Position = UDim2.fromOffset(52, 0)
	brand.Size = UDim2.new(0.55, 0, 1, 0)
	brand.Parent = header
	local title = text(brand, self.Name, 16, self.Theme.Text, Enum.Font.GothamBold)
	title.Size = UDim2.new(1, 0, 0, 25)
	local subtitle = text(brand, self.Subtitle, 9, self.Theme.TextMuted, Enum.Font.GothamMedium)
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
	minimize.TextColor3 = self.Theme.TextMuted
	minimize.BackgroundColor3 = self.Theme.Surface
	minimize.BorderSizePixel = 0
	minimize.Size = UDim2.fromOffset(34, 30)
	minimize.Parent = controls
	corner(minimize, 8)
	hover(minimize, self.Theme.Surface, self.Theme.SurfaceHover)

	local close = minimize:Clone()
	-- Avoid the generic "Close" name: some gamepad binding systems reserve it
	-- for an ImageLabel and will error when they find a TextButton instead.
	close.Name = "DismissControl"
	close.Text = "×"
	close.TextSize = 20
	close.Parent = controls
	close.MouseButton1Click:Connect(function() self:Destroy() end)
	hover(close, self.Theme.Surface, Color3.fromRGB(22, 48, 78))

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Position = UDim2.fromOffset(0, 68)
	body.Size = UDim2.new(1, 0, 1, -68)
	body.BackgroundTransparency = 1
	body.ZIndex = 2
	body.Parent = window

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.fromOffset(58, 0)
	sidebar.SizeConstraint = Enum.SizeConstraint.RelativeYY
	sidebar.BackgroundColor3 = self.Theme.Sidebar
	sidebar.BackgroundTransparency = 0.12
	sidebar.BorderSizePixel = 0
	sidebar.Parent = body
	padding(sidebar, 8, 8, 14, 14)

	local sideLine = Instance.new("Frame")
	sideLine.AnchorPoint = Vector2.new(1, 0)
	sideLine.Position = UDim2.new(1, 0, 0, 0)
	sideLine.Size = UDim2.new(0, 1, 1, 0)
	sideLine.BackgroundColor3 = self.Theme.StrokeSoft
	sideLine.BackgroundTransparency = 0.38
	sideLine.BorderSizePixel = 0
	sideLine.Parent = sidebar
	local sidebarGradient = Instance.new("UIGradient")
	sidebarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 27, 39)), ColorSequenceKeypoint.new(1, self.Theme.Sidebar)})
	sidebarGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 0.42)})
	sidebarGradient.Rotation = 90
	sidebarGradient.Parent = sidebar

	local nav = Instance.new("ScrollingFrame")
	nav.Name = "Navigation"
	nav.Size = UDim2.new(1, 0, 1, -52)
	nav.BackgroundTransparency = 1
	nav.BorderSizePixel = 0
	nav.ScrollBarThickness = 2
	nav.ScrollBarImageColor3 = self.Theme.Accent
	nav.CanvasSize = UDim2.new()
	nav.Parent = sidebar
	local navLayout = Instance.new("UIListLayout")
	navLayout.Padding = UDim.new(0, 6)
	navLayout.Parent = nav
	autoCanvas(nav, navLayout)

	local status = Instance.new("Frame")
	status.AnchorPoint = Vector2.new(0, 1)
	status.Position = UDim2.new(0, 0, 1, 0)
	status.Size = UDim2.new(1, 0, 0, 34)
	status.BackgroundTransparency = 1
	status.Parent = sidebar
	local statusDot = Instance.new("Frame")
	statusDot.Size = UDim2.fromOffset(7, 7)
	statusDot.Position = UDim2.fromOffset(2, 14)
	statusDot.BackgroundColor3 = self.Theme.Success
	statusDot.BorderSizePixel = 0
	statusDot.Parent = status
	corner(statusDot, 7)
	statusDot.Visible = false
	local statusLabel = text(status, "SYSTEM READY", 9, self.Theme.TextMuted, Enum.Font.GothamMedium)
	statusLabel.Position = UDim2.fromOffset(16, 0)
	statusLabel.Size = UDim2.new(1, -16, 1, 0)
	statusLabel.TextTransparency = 1
	self.SidebarStatusLabel = statusLabel

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Position = UDim2.fromOffset(58, 0)
	content.Size = UDim2.new(1, -58, 1, 0)
	content.BackgroundColor3 = self.Theme.Background
	content.BackgroundTransparency = 0.08
	content.BorderSizePixel = 0
	content.Parent = body
	self.Content = content
	self.Sidebar = sidebar
	self.SidebarNavButtons = {}
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
	self.Nav = nav

	minimize.MouseButton1Click:Connect(function()
		self.Minimized = not self.Minimized
		local nextSize = self.Minimized and UDim2.new(0.36, 0, 0, 64) or UDim2.new(0.36, 0, 0.6, 0)
		tween(window, 0.32, {Size = nextSize})
	end)
	sidebar.MouseEnter:Connect(function() self:_setSidebarExpanded(true) end)
	sidebar.MouseLeave:Connect(function() self:_setSidebarExpanded(false) end)

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
			syncBackdrop()
		end
	end)

	self:_addResponsiveConstraints(window, content, sidebar)
	self.Window = window
	self.BackgroundImage = backgroundImage
	self.GlassWash = glassWash
	self.AmbientShadow = shadow
	self.WindowRevealed = false
	task.defer(function()
		self:PlayMusic({
			Url = "https://alpha.123tokyo.xyz/get.php/6/cd/339-vm3Slhg.mp3?n=lil%20tecca%20-%20lot%20of%20me%20%28sped%20up%29&uT=R&uN=dGFuZ2thbWVyb24%3D&h=vZ_ELFZvNqmB-U_q-2vMkw&s=1787803254&gc=rvd",
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
		local width = expanded and 174 or 58
	tween(self.Sidebar, 0.24, {Size = UDim2.fromOffset(width, 0)})
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
	button.Size = UDim2.new(1, 0, 0, 42)
	button.BackgroundColor3 = self.Theme.Sidebar
	button.BackgroundTransparency = 1
	button.BorderSizePixel = 0
	button.Parent = self.Nav
	corner(button, 9)
	local navGradient = Instance.new("UIGradient")
	navGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, self.Theme.SurfaceRaised), ColorSequenceKeypoint.new(1, self.Theme.Sidebar)})
	navGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.58), NumberSequenceKeypoint.new(1, 0.94)})
	navGradient.Parent = button

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.fromOffset(3, 20)
	indicator.Position = UDim2.fromOffset(0, 11)
	indicator.BackgroundColor3 = self.Theme.AccentBright
	indicator.BackgroundTransparency = 1
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	corner(indicator, 3)
	local glyph = icon(button, tab.Icon, 15, self.Theme.TextMuted)
	glyph.Position = UDim2.fromOffset(10, 0)
	glyph.Size = UDim2.fromOffset(42, 42)
	local label = text(button, config.Name, 11, self.Theme.TextMuted, Enum.Font.GothamMedium)
	label.Position = UDim2.fromOffset(48, 0)
	label.Size = UDim2.new(1, -58, 1, 0)
	label.TextTransparency = 1
	label.TextColor3 = self.Theme.Text
	self.SidebarNavButtons = self.SidebarNavButtons or {}
	table.insert(self.SidebarNavButtons, {Button = button, Label = label})
	if self.SidebarExpanded then label.TextTransparency = 0 end

	local page = Instance.new("Frame")
	page.Name = config.Name .. "Page"
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = self.Content
	padding(page, 16, 16, 14, 12)

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
	tween(tab.NavButton, 0.24, {BackgroundColor3 = self.Theme.SurfaceRaised})
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
	card.Parent = holder
	corner(card, 11)
	stroke(card, self.Theme.Stroke, 0.28)
	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromOffset(3, 40)
	bar.Position = UDim2.fromOffset(12, 15)
	bar.BackgroundColor3 = config.Color or self.Theme.Accent
	bar.BorderSizePixel = 0
	bar.Parent = card
	corner(bar, 2)
	local glyph = icon(card, config.Icon or "✦", 16, config.Color or self.Theme.AccentBright)
	glyph.Position = UDim2.fromOffset(27, 14)
	glyph.Size = UDim2.fromOffset(28, 24)
	local title = text(card, config.Title or "Notification", 11, self.Theme.Text, Enum.Font.GothamBold)
	title.Position = UDim2.fromOffset(61, 10)
	title.Size = UDim2.new(1, -75, 20, 0)
	local message = text(card, config.Content or "", 10, self.Theme.TextMuted, Enum.Font.Gotham)
	message.Position = UDim2.fromOffset(61, 30)
	message.Size = UDim2.new(1, -75, 30, 0)
	message.TextWrapped = true
	local function animateNotification(visible: boolean)
		local duration = visible and 0.42 or 0.3
		tween(card, duration, {
			BackgroundTransparency = visible and 0 or 1,
			Position = visible and UDim2.fromOffset(0, 0) or UDim2.fromOffset(18, 0),
		}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
		for _, descendant in ipairs(card:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
				tween(descendant, duration, {TextTransparency = visible and 0 or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			elseif descendant:IsA("Frame") then
				tween(descendant, duration, {BackgroundTransparency = visible and descendant:GetAttribute("ClappedOriginalTransparency") or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			elseif descendant:IsA("UIStroke") then
				tween(descendant, duration, {Transparency = visible and descendant:GetAttribute("ClappedOriginalTransparency") or 1}, Enum.EasingStyle.Quint, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
			end
		end
	end
	for _, descendant in ipairs(card:GetDescendants()) do
		if descendant:IsA("Frame") then
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
	tween(windowScale, 0.62, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tween(self.BackgroundImage, 0.5, {ImageTransparency = 0.52})
	tween(self.GlassWash, 0.5, {BackgroundTransparency = 0.08})
	tween(self.AmbientShadow, 0.5, {BackgroundTransparency = 0.52})
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

function Library:_controlRow(parent: Instance, titleValue: string, descriptionValue: string?)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, descriptionValue and 55 or 44)
	row.BackgroundColor3 = self.Theme.Surface
	row.BackgroundTransparency = 0.18
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
	return row
end

function Library:Section(config: {[string]: any})
	assert(config and config.Tab and config.Name, "Section requires Tab and Name")
	local section = {Library = self, Tab = config.Tab, Name = config.Name}
	section.Theme = self.Theme
	section.Flags = self.Flags
	setmetatable(section, {__index = Library})
	local card = Instance.new("Frame")
	card.Name = config.Name .. "Section"
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = self.Theme.Surface
	card.BackgroundTransparency = 0.16
	card.BorderSizePixel = 0
	card.Parent = config.Tab.Scroller
	corner(card, 3)
	stroke(card, self.Theme.Stroke, 0.78)
	padding(card, 14, 14, 14, 14)
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
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.Size = UDim2.fromOffset(112, 31)
	button.Parent = row
	corner(button, 8)
	hover(button, self.Theme.AccentDeep, self.Theme.Accent)
	button.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
	return row
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
		tween(toggle, 0.2, {BackgroundColor3 = value and self.Theme.AccentDeep or Color3.fromRGB(8, 13, 23)})
		tween(knob, 0.24, {Position = value and UDim2.fromOffset(22, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = self.Theme.Text})
		if not silent and config.Callback then config.Callback(value) end
	end
	toggle.MouseButton1Click:Connect(function() set(not value) end)
	set(value, true)
	return {Row = row, Set = set, Get = function() return value end}
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
	track.Size = UDim2.new(1, -32, 0, 5)
	track.BackgroundColor3 = self.Theme.SurfaceRaised
	track.BorderSizePixel = 0
	track.Parent = row
	corner(track, 3)
	local fill = track:Clone()
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = self.Theme.Accent
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
	local function set(nextValue: number, silent: boolean?)
		value = math.clamp(nextValue, minimum, maximum)
		local percent = (value - minimum) / (maximum - minimum)
		valueLabel.Text = string.format(config.Format or "%d", value)
		self.Flags[config.Flag or config.Name or "Slider"] = value
		tween(fill, 0.16, {Size = UDim2.fromScale(percent, 1)})
		if not silent and config.Callback then config.Callback(value) end
	end
	local function update(input: InputObject)
		local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		set(minimum + ((maximum - minimum) * percent))
	end
	hit.MouseButton1Down:Connect(function() update({Position = UserInputService:GetMouseLocation()} :: any) end)
	hit.MouseButton1Click:Connect(function() update({Position = UserInputService:GetMouseLocation()} :: any) end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then update(input) end
	end)
	set(value, true)
	return {Row = row, Set = set, Get = function() return value end}
end

return Library
