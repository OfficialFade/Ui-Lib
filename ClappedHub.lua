--!strict
-- Clapped Hub UI Lib
-- Premium, UI-only Roblox interface primitives.
-- This module owns presentation and state only. It does not perform gameplay,
-- automation, exploit, or external action logic.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

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
	item.Font = font or Enum.Font.GothamMedium
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

local function colorToHex(value: Color3): string
	return string.format("#%02X%02X%02X", math.floor(value.R * 255 + 0.5), math.floor(value.G * 255 + 0.5), math.floor(value.B * 255 + 0.5))
end

local function colorFromHex(value: string): Color3?
	local hex = string.gsub(value or "", "#", "")
	if not string.match(hex, "^%x%x%x%x%x%x$") then return nil end
	local red = tonumber(string.sub(hex, 1, 2), 16)
	local green = tonumber(string.sub(hex, 3, 4), 16)
	local blue = tonumber(string.sub(hex, 5, 6), 16)
	if not red or not green or not blue then return nil end
	return Color3.fromRGB(red, green, blue)
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
	self.ProfileUserName = options.ProfileUserName or LocalPlayer.Name
	local scriptType = string.upper(tostring(options.ScriptType or "FREE"))
	self.ScriptType = scriptType == "PAID" and "PAID" or "FREE"
	self.Theme = table.clone(Library.Theme)
	self.Flags = {}
	self.FlagControls = {}
	self.Tabs = {}
	self.ActiveTab = nil
	self.Destroyed = false
	self.SearchEntries = {}
	self.KeybindOrder = {}
	self.Keybinds = {}
	self.ActiveKeybindPicker = nil
	self.KeybindPanel = nil
	self.KeybindPanelToggle = nil
	self.ActiveDropdown = nil
	self.ActiveColorPicker = nil
	self.Minimized = false
	self.HubVisible = true
	self.HubToggleBind = nil
	self.ColorPickerDragConnections = {}
	self.CollapsibleSidebar = options.CollapsibleSidebar == true
	self.AutoCollapseSidebar = options.AutoCollapseSidebar == true or self.CollapsibleSidebar
	self.SidebarExpandedWidth = options.SidebarExpandedWidth or 170
	self.SidebarCollapsedWidth = options.SidebarCollapsedWidth or 58
	self.SidebarCollapseDelay = options.SidebarCollapseDelay or 0
	self.SidebarCollapseToken = 0
	self.EnableLoadingMusic = options.EnableLoadingMusic ~= false
	self.EnableDragging = options.EnableDragging ~= false
	self.EnableMinimize = options.EnableMinimize ~= false
	self.ShowSearch = options.ShowSearch ~= false
	self.ShowProfile = options.ShowProfile ~= false
	self.ShowBackground = options.ShowBackground ~= false
	self.LogoImage = options.IconImage or options.Icon or options.LogoImage or "rbxassetid://101595980825854"
	self.UseAspectRatio = options.WindowSize == nil and options.AspectRatio ~= false
	self.WindowMinSize = options.WindowMinSize or Vector2.new(330, 400)
	self.WindowMaxSize = options.WindowMaxSize or Vector2.new(520, 620)
	self.WindowAspectRatio = options.AspectRatio or 1.04
	self.WindowPosition = options.WindowPosition or UDim2.fromScale(0.5, 0.5)
	local configuredSize = options.WindowSize
	if typeof(configuredSize) == "Vector2" then
		configuredSize = UDim2.fromOffset(configuredSize.X, configuredSize.Y)
	end
	self.WindowSize = configuredSize or UDim2.new(0.36, 0, 0.6, 0)

	if type(options.Theme) == "table" then
		for key, value in pairs(options.Theme) do
			if self.Theme[key] ~= nil then self.Theme[key] = value end
		end
	end
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
	shadow.Position = self.WindowPosition
	shadow.Size = self.WindowSize
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

	local windowGroup = Instance.new("CanvasGroup")
	windowGroup.Name = "WindowGroup"
	windowGroup.Size = UDim2.fromScale(1, 1)
	windowGroup.BackgroundTransparency = 1
	windowGroup.BorderSizePixel = 0
	windowGroup.ZIndex = 2
	windowGroup.Parent = gui
	self.WindowGroup = windowGroup

	local window = Instance.new("Frame")
	window.Name = "Window"
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.Position = self.WindowPosition
	window.Size = self.WindowSize
	window.BackgroundColor3 = self.Theme.Window
	window.BackgroundTransparency = 1
	window.BorderSizePixel = 0
	window.ClipsDescendants = true
	window.ZIndex = 2
	window.Visible = false
	window.Parent = windowGroup
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
	logo.Image = self.LogoImage
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
	controls.Position = UDim2.new(1, -16, 0.5, 0)
	controls.Size = UDim2.fromOffset(78, 32)
	controls.Parent = header
	local controlLayout = Instance.new("UIListLayout")
	controlLayout.FillDirection = Enum.FillDirection.Horizontal
	controlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	controlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	controlLayout.Padding = UDim.new(0, 6)
	controlLayout.Parent = controls

	local minimize = Instance.new("TextButton")
	minimize.AutoButtonColor = false
	minimize.Text = "—"
	minimize.TextSize = 17
	minimize.Font = Enum.Font.GothamMedium
	minimize.TextColor3 = self.Theme.Text
	minimize.BackgroundColor3 = self.Theme.StrokeSoft
	minimize.BorderSizePixel = 0
	minimize.Size = UDim2.fromOffset(36, 32)
	minimize.Parent = controls
	minimize.Visible = self.EnableMinimize
	corner(minimize, 9)
	minimize.BackgroundColor3 = self.Theme.AccentDeep
	hover(minimize, self.Theme.AccentDeep, self.Theme.Accent)

	local close = minimize:Clone()
	-- Avoid the generic "Close" name: some gamepad binding systems reserve it
	-- for an ImageLabel and will error when they find a TextButton instead.
	close.Name = "DismissControl"
	close.Text = "×"
	close.TextSize = 18
	close.Parent = controls
	close.MouseButton1Click:Connect(function() self:Destroy() end)
	close.BackgroundColor3 = self.Theme.Danger
	close.BackgroundTransparency = 0.18
	hover(close, self.Theme.Danger, Color3.fromRGB(255, 120, 135))

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Position = UDim2.fromOffset(0, 68)
	body.Size = UDim2.new(1, 0, 1, -68)
	body.BackgroundTransparency = 1
	body.ZIndex = 2
	body.ClipsDescendants = true
	body.Parent = window
	corner(body, 20)
	self.Body = body

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

	local sidebarSearch = Instance.new("Frame")
	sidebarSearch.Name = "SettingsSearch"
	sidebarSearch.Position = UDim2.fromOffset(8, 10)
	sidebarSearch.Size = UDim2.new(1, -16, 0, 32)
	sidebarSearch.BackgroundColor3 = self.Theme.Surface
	sidebarSearch.BackgroundTransparency = 0.28
	sidebarSearch.BorderSizePixel = 0
	sidebarSearch.ZIndex = 5
	sidebarSearch.Parent = sidebar
	corner(sidebarSearch, 9)
	stroke(sidebarSearch, self.Theme.StrokeSoft, 0.42)
	local searchIcon = Instance.new("Frame")
	searchIcon.Name = "SearchIcon"
	searchIcon.Position = UDim2.fromOffset(10, 8)
	searchIcon.Size = UDim2.fromOffset(18, 18)
	searchIcon.BackgroundTransparency = 1
	searchIcon.BorderSizePixel = 0
	searchIcon.ZIndex = 6
	searchIcon.Parent = sidebarSearch
	local searchLens = Instance.new("Frame")
	searchLens.Size = UDim2.fromOffset(11, 11)
	searchLens.Position = UDim2.fromOffset(1, 1)
	searchLens.BackgroundTransparency = 1
	searchLens.BorderSizePixel = 0
	searchLens.ZIndex = 6
	searchLens.Parent = searchIcon
	corner(searchLens, 6)
	stroke(searchLens, self.Theme.AccentBright, 0.04, 1.5)
	local searchHandle = Instance.new("Frame")
	searchHandle.Size = UDim2.fromOffset(7, 2)
	searchHandle.Position = UDim2.fromOffset(10, 12)
	searchHandle.Rotation = 45
	searchHandle.BackgroundColor3 = self.Theme.AccentBright
	searchHandle.BorderSizePixel = 0
	searchHandle.ZIndex = 6
	searchHandle.Parent = searchIcon
	corner(searchHandle, 1)
	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Position = UDim2.fromOffset(32, 0)
	searchBox.Size = UDim2.new(1, -38, 1, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Enum.Font.Gotham
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search..."
	searchBox.PlaceholderColor3 = self.Theme.TextMuted
	searchBox.TextColor3 = self.Theme.Text
	searchBox.TextSize = 10
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ZIndex = 6
	searchBox.Parent = sidebarSearch
	self.SearchBar = sidebarSearch
	self.SearchBox = searchBox
	self.SearchIcon = searchIcon

	local sidebarGradient = Instance.new("UIGradient")
	sidebarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 27, 39)), ColorSequenceKeypoint.new(1, self.Theme.Sidebar)})
	sidebarGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 0.42)})
	sidebarGradient.Rotation = 90
	sidebarGradient.Parent = sidebar

	local nav = Instance.new("ScrollingFrame")
	nav.Name = "Navigation"
	nav.Position = UDim2.fromOffset(0, 50)
	nav.Size = UDim2.new(1, 0, 1, -132)
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

	local userCard = Instance.new("Frame")
	userCard.Name = "UserCard"
	userCard.Position = UDim2.new(0, 8, 1, -76)
	userCard.Size = UDim2.new(1, -16, 0, 66)
	userCard.BackgroundColor3 = self.Theme.Surface
	userCard.BackgroundTransparency = 0.34
	userCard.BorderSizePixel = 0
	userCard.ClipsDescendants = true
	userCard.ZIndex = 4
	userCard.Parent = sidebar
	corner(userCard, 11)
	stroke(userCard, self.Theme.StrokeSoft, 0.34)
	local avatar = Instance.new("ImageLabel")
	avatar.Name = "ProfileIcon"
	avatar.Position = UDim2.fromOffset(9, 9)
	avatar.Size = UDim2.fromOffset(38, 38)
	avatar.BackgroundColor3 = self.Theme.StrokeSoft
	avatar.BackgroundTransparency = 0.18
	avatar.BorderSizePixel = 0
	avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
	avatar.ScaleType = Enum.ScaleType.Crop
	avatar.ZIndex = 5
	avatar.Parent = userCard
	corner(avatar, 19)
	stroke(avatar, self.Theme.AccentDeep, 0.12, 1.25)
	local username = text(userCard, self.ProfileUserName, 10, self.Theme.Text, Enum.Font.GothamBold)
	username.Position = UDim2.fromOffset(56, 7)
	username.Size = UDim2.new(1, -64, 0, 20)
	username.TextTruncate = Enum.TextTruncate.AtEnd
	username.ZIndex = 5
	local typeBadge = Instance.new("Frame")
	typeBadge.Name = "ScriptTypeBadge"
	typeBadge.Position = UDim2.fromOffset(56, 34)
	typeBadge.Size = UDim2.fromOffset(66, 20)
	typeBadge.BackgroundColor3 = self.ScriptType == "PAID" and self.Theme.AccentDeep or self.Theme.Success
	typeBadge.BackgroundTransparency = 0.12
	typeBadge.BorderSizePixel = 0
	typeBadge.ZIndex = 5
	typeBadge.Parent = userCard
	corner(typeBadge, 6)
	stroke(typeBadge, self.Theme.Text, 0.62)
	local typeLabel = text(typeBadge, self.ScriptType, 8, self.Theme.Text, Enum.Font.GothamBold)
	typeLabel.Size = UDim2.fromScale(1, 1)
	typeLabel.TextXAlignment = Enum.TextXAlignment.Center
	typeLabel.ZIndex = 6
	self.UserCard = userCard

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
	self.SearchBar.Visible = self.ShowSearch
	self.SearchBox.Visible = self.ShowSearch
	self.UserCard.Visible = self.ShowProfile
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

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		self:_applySearch(searchBox.Text)
	end)
	self.Nav = nav

	local searchTab = {Library = self, Name = "Search Results", Icon = "⌕", Sections = {}}
	setmetatable(searchTab, {__index = Library})
	local searchTabButton = Instance.new("TextButton")
	searchTabButton.Name = "SearchResultsNav"
	searchTabButton.AutoButtonColor = false
	searchTabButton.Text = ""
	searchTabButton.Size = UDim2.new(1, 0, 0, 50)
	searchTabButton.BackgroundColor3 = self.Theme.StrokeSoft
	searchTabButton.BackgroundTransparency = 0.42
	searchTabButton.BorderSizePixel = 0
	searchTabButton.ZIndex = 4
	searchTabButton.Visible = false
	searchTabButton.Parent = nav
	corner(searchTabButton, 9)
	local searchTabIndicator = Instance.new("Frame")
	searchTabIndicator.Size = UDim2.fromOffset(3, 26)
	searchTabIndicator.Position = UDim2.fromOffset(0, 12)
	searchTabIndicator.BackgroundColor3 = self.Theme.AccentDeep
	searchTabIndicator.BackgroundTransparency = 1
	searchTabIndicator.BorderSizePixel = 0
	searchTabIndicator.ZIndex = 6
	searchTabIndicator.Parent = searchTabButton
	corner(searchTabIndicator, 3)
	local searchTabGlyph = icon(searchTabButton, searchTab.Icon, 17, self.Theme.TextMuted)
	searchTabGlyph.Position = UDim2.fromOffset(10, 0)
	searchTabGlyph.Size = UDim2.fromOffset(42, 50)
	searchTabGlyph.ZIndex = 6
	local searchTabLabel = text(searchTabButton, searchTab.Name, 12, self.Theme.Text, Enum.Font.GothamMedium)
	searchTabLabel.Position = UDim2.fromOffset(48, 0)
	searchTabLabel.Size = UDim2.new(1, -58, 1, 0)
	searchTabLabel.ZIndex = 6
	searchTabButton.MouseEnter:Connect(function() tween(searchTabButton, 0.16, {BackgroundColor3 = self.Theme.AccentDeep}) end)
	searchTabButton.MouseLeave:Connect(function() tween(searchTabButton, 0.2, {BackgroundColor3 = self.Theme.StrokeSoft}) end)
	searchTabButton.MouseButton1Click:Connect(function() self:SelectTab(searchTab) end)

	local searchPage = Instance.new("Frame")
	searchPage.Name = "SearchResultsPage"
	searchPage.Size = UDim2.fromScale(1, 1)
	searchPage.BackgroundTransparency = 1
	searchPage.Visible = false
	searchPage.Parent = content
	padding(searchPage, 16, 16, 16, 12)
	local searchPageHeader = text(searchPage, "Search Results", 24, self.Theme.Text, Enum.Font.GothamBold)
	searchPageHeader.Size = UDim2.new(1, 0, 0, 28)
	local searchPageDescription = text(searchPage, "Search settings from the tabs area.", 11, self.Theme.TextMuted, Enum.Font.Gotham)
	searchPageDescription.Position = UDim2.fromOffset(0, 29)
	searchPageDescription.Size = UDim2.new(1, 0, 0, 24)
	local searchResultsList = Instance.new("ScrollingFrame")
	searchResultsList.Name = "Results"
	searchResultsList.Position = UDim2.fromOffset(0, 58)
	searchResultsList.Size = UDim2.new(1, 0, 1, -58)
	searchResultsList.BackgroundTransparency = 1
	searchResultsList.BorderSizePixel = 0
	searchResultsList.ScrollBarThickness = 3
	searchResultsList.ScrollBarImageColor3 = self.Theme.Accent
	searchResultsList.CanvasSize = UDim2.new()
	searchResultsList.Parent = searchPage
	local searchResultsLayout = Instance.new("UIListLayout")
	searchResultsLayout.Padding = UDim.new(0, 8)
	searchResultsLayout.Parent = searchResultsList
	autoCanvas(searchResultsList, searchResultsLayout)
	local searchEmpty = text(searchPage, "No matching settings.", 10, self.Theme.TextMuted, Enum.Font.Gotham)
	searchEmpty.Position = UDim2.fromOffset(0, 124)
	searchEmpty.Size = UDim2.new(1, 0, 0, 24)
	searchEmpty.TextXAlignment = Enum.TextXAlignment.Center
	searchEmpty.Visible = false
	searchTab.Page = searchPage
	searchTab.NavButton = searchTabButton
	searchTab.NavIndicator = searchTabIndicator
	searchTab.NavIcon = searchTabGlyph
	searchTab.NavLabel = searchTabLabel
	self.SearchResultTab = searchTab
	self.SearchResultDescription = searchPageDescription
	self.SearchResultsList = searchResultsList
	self.SearchResultsEmpty = searchEmpty
	self.Header = header
	self.HeaderControls = controls
	self.MinimizeButton = minimize
	self.BrandTitle = title
	self.BrandSubtitle = subtitle
	self.BrandMark = brandMark
	self.Brand = brand
	self.BrandLogo = logo
	self.TopGlow = topGlow
	local minimizedHitbox = Instance.new("TextButton")
	minimizedHitbox.Name = "RestoreWindow"
	minimizedHitbox.Text = ""
	minimizedHitbox.BackgroundTransparency = 1
	minimizedHitbox.BorderSizePixel = 0
	minimizedHitbox.Size = UDim2.fromScale(1, 1)
	minimizedHitbox.Visible = false
	minimizedHitbox.ZIndex = 10
	minimizedHitbox.Parent = header
	self.MinimizedHitbox = minimizedHitbox
	minimizedHitbox.MouseButton1Click:Connect(function() self:_setMinimized(false) end)

	minimize.MouseButton1Click:Connect(function()
		self:_setMinimized(not self.Minimized)
	end)
	sidebar.MouseEnter:Connect(function()
		self.SidebarCollapseToken += 1
		if self.AutoCollapseSidebar then self:_setSidebarExpanded(true) end
	end)
	sidebar.MouseLeave:Connect(function()
		if not self.AutoCollapseSidebar then return end
		self.SidebarCollapseToken += 1
		local token = self.SidebarCollapseToken
		if self.SidebarCollapseDelay > 0 then
			task.delay(self.SidebarCollapseDelay, function()
				if not self.Destroyed and token == self.SidebarCollapseToken then self:_setSidebarExpanded(false) end
			end)
		else
			self:_setSidebarExpanded(false)
		end
	end)

	if self.EnableDragging then
		local dragging, dragStart, startPosition, dragMoved
		header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPosition = window.Position
				dragMoved = false
			end
		end)
		header.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
				if self.Minimized and not dragMoved then self:_setMinimized(false) end
			end
		end)
		self.WindowDragConnection = UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				dragMoved = math.abs(delta.X) > 3 or math.abs(delta.Y) > 3
				local nextPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
				window.Position = nextPosition
				shadow.Position = nextPosition
			end
		end)
	end

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
	sizeConstraint.MinSize = self.WindowMinSize
	sizeConstraint.MaxSize = self.WindowMaxSize
	sizeConstraint.Parent = window
	self.WindowSizeConstraint = sizeConstraint
	local sidebarConstraint = Instance.new("UISizeConstraint")
	sidebarConstraint.MinSize = Vector2.new(58, 0)
	sidebarConstraint.MaxSize = Vector2.new(184, math.huge)
	sidebarConstraint.Parent = sidebar
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectRatio = self.WindowAspectRatio
	aspect.DominantAxis = Enum.DominantAxis.Width
	if self.UseAspectRatio then aspect.Parent = window end
	self.WindowAspectConstraint = aspect
end

function Library:_setSidebarExpanded(expanded: boolean)
	if self.SidebarExpanded == expanded then return end
	self.SidebarExpanded = expanded
	local width = expanded and self.SidebarExpandedWidth or self.SidebarCollapsedWidth
	tween(self.Sidebar, 0.34, {Size = UDim2.new(0, width, 1, 0)})
	tween(self.Content, 0.34, {Position = UDim2.fromOffset(width, 0), Size = UDim2.new(1, -width, 1, 0)})
	for _, item in ipairs(self.SidebarNavButtons) do
		tween(item.Label, 0.28, {TextTransparency = expanded and 0 or 1})
		tween(item.Button, 0.34, {BackgroundTransparency = expanded and 0.42 or 1})
	end
	if self.SearchBox then
		self.SearchBox.Visible = expanded and self.ShowSearch
		tween(self.SearchBox, 0.28, {TextTransparency = expanded and 0 or 1})
		tween(self.SearchBox, 0.28, {PlaceholderColor3 = expanded and self.Theme.TextMuted or self.Theme.TextFaint})
	end
	if self.SearchBar then
		tween(self.SearchBar, 0.34, {
			Position = expanded and UDim2.fromOffset(8, 10) or UDim2.fromOffset(math.floor((self.SidebarCollapsedWidth - 32) / 2), 10),
			Size = expanded and UDim2.new(1, -16, 0, 32) or UDim2.fromOffset(32, 32),
		})
	end
	if self.SearchIcon then
		if expanded then
			self.SearchIcon.AnchorPoint = Vector2.new(0, 0)
			tween(self.SearchIcon, 0.34, {Position = UDim2.fromOffset(10, 8)})
		else
			self.SearchIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			tween(self.SearchIcon, 0.34, {Position = UDim2.fromScale(0.5, 0.5)})
		end
	end
	if self.UserCard then self.UserCard.Visible = expanded and self.ShowProfile end
	if self.SidebarStatusLabel then tween(self.SidebarStatusLabel, 0.18, {TextTransparency = expanded and 0.12 or 1}) end
end

function Library:_setMinimized(minimized: boolean)
	if self.Destroyed or self.Minimized == minimized then return end
	self.Minimized = minimized
	if minimized then
		if self.WindowAspectConstraint then self.WindowAspectConstraint.Parent = nil end
		if self.WindowSizeConstraint then self.WindowSizeConstraint.Parent = nil end
		self.Body.Visible = false
		self.HeaderControls.Visible = self.EnableMinimize
		self.MinimizeButton.Text = "+"
		self.TopGlow.Visible = false
		self.MinimizedHitbox.Visible = false
		if self.BrandMark then
			self.BrandMark.AnchorPoint = Vector2.new(0.5, 0.5)
			self.BrandMark.Position = UDim2.new(0.5, -71, 0.5, 0)
		end
		if self.Brand then
			self.Brand.AnchorPoint = Vector2.new(0, 0.5)
			self.Brand.Position = UDim2.new(0.5, -25, 0.5, 0)
			self.Brand.Size = UDim2.fromOffset(114, 36)
		end
		if self.BrandTitle then self.BrandTitle.TextXAlignment = Enum.TextXAlignment.Center end
		tween(self.Header, 0.28, {Size = UDim2.new(1, 0, 0, 58)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		tween(self.BrandSubtitle, 0.18, {TextTransparency = 1})
		tween(self.Window, 0.36, {Size = UDim2.fromOffset(320, 58)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if self.AmbientShadow then tween(self.AmbientShadow, 0.36, {Size = UDim2.fromOffset(320, 58)}) end
	else
		self.HeaderControls.Visible = true
		self.MinimizeButton.Text = "—"
		self.TopGlow.Visible = true
		self.Body.Visible = true
		self.MinimizedHitbox.Visible = false
		if self.WindowSizeConstraint then self.WindowSizeConstraint.Parent = self.Window end
		if self.BrandMark then
			self.BrandMark.AnchorPoint = Vector2.new(0, 0)
			self.BrandMark.Position = UDim2.fromOffset(0, 0)
		end
		if self.Brand then
			self.Brand.AnchorPoint = Vector2.new(0, 0)
			self.Brand.Position = UDim2.fromOffset(52, 0)
			self.Brand.Size = UDim2.new(0.55, 0, 1, 0)
		end
		if self.BrandTitle then self.BrandTitle.TextXAlignment = Enum.TextXAlignment.Left end
		tween(self.Header, 0.28, {Size = UDim2.new(1, 0, 0, 68)}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		tween(self.BrandSubtitle, 0.18, {TextTransparency = 0.08})
		tween(self.Window, 0.42, {Size = self.WindowSize}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		if self.AmbientShadow then tween(self.AmbientShadow, 0.42, {Size = self.WindowSize}) end
		task.delay(0.44, function()
			if not self.Destroyed and not self.Minimized and self.UseAspectRatio and self.WindowAspectConstraint then
				self.WindowAspectConstraint.Parent = self.Window
			end
		end)
	end
end

function Library:SetWindowSize(size: UDim2 | Vector2)
	if self.Destroyed or not self.Window then return end
	if typeof(size) == "Vector2" then size = UDim2.fromOffset(size.X, size.Y) end
	assert(typeof(size) == "UDim2", "SetWindowSize requires UDim2 or Vector2")
	self.WindowSize = size
	self.UseAspectRatio = false
	if self.WindowAspectConstraint then self.WindowAspectConstraint.Parent = nil end
	tween(self.Window, 0.25, {Size = size})
	if self.AmbientShadow then tween(self.AmbientShadow, 0.25, {Size = size}) end
end

function Library:SetWindowPosition(position: UDim2)
	if self.Destroyed or not self.Window then return end
	assert(typeof(position) == "UDim2", "SetWindowPosition requires UDim2")
	self.WindowPosition = position
	tween(self.Window, 0.25, {Position = position})
	if self.AmbientShadow then tween(self.AmbientShadow, 0.25, {Position = position}) end
end

function Library:SetSearchVisible(visible: boolean)
	self.ShowSearch = visible == true
	if self.SearchBar then self.SearchBar.Visible = self.ShowSearch end
	if self.SearchBox then self.SearchBox.Visible = self.ShowSearch end
end

function Library:SetProfileVisible(visible: boolean)
	self.ShowProfile = visible == true
	if self.UserCard then self.UserCard.Visible = self.ShowProfile and self.SidebarExpanded end
end

function Library:SetSidebarAutoCollapse(enabled: boolean)
	self.AutoCollapseSidebar = enabled == true
	if not self.AutoCollapseSidebar then self:_setSidebarExpanded(true) end
end

function Library:SetTheme(theme: {[string]: any})
	assert(type(theme) == "table", "SetTheme requires a table")
	for key, value in pairs(theme) do
		if self.Theme[key] ~= nil then self.Theme[key] = value end
	end
	if self.Window then self.Window.BackgroundColor3 = self.Theme.Window end
	if self.Sidebar then self.Sidebar.BackgroundColor3 = self.Theme.Sidebar end
	if self.Content then self.Content.BackgroundColor3 = self.Theme.Background end
	if self.TopGlow then self.TopGlow.BackgroundColor3 = self.Theme.AccentBright end
	if self.Nav then self.Nav.ScrollBarImageColor3 = self.Theme.Accent end
	return self.Theme
end

function Library:SetAccent(color: Color3)
	assert(typeof(color) == "Color3", "SetAccent requires Color3")
	return self:SetTheme({Accent = color})
end

function Library:SetBackgroundVisible(visible: boolean)
	self.ShowBackground = visible == true
	if self.BackgroundImage then self.BackgroundImage.Visible = self.ShowBackground and self.WindowRevealed end
	if self.GlassWash then self.GlassWash.Visible = self.ShowBackground and self.WindowRevealed end
end

function Library:SetBackgroundImage(image: string, transparency: number?)
	assert(type(image) == "string", "SetBackgroundImage requires an asset id string")
	if self.BackgroundImage then
		self.BackgroundImage.Image = image
		if transparency ~= nil then
			self.BackgroundImage.ImageTransparency = math.clamp(transparency, 0, 1)
		end
	end
	self.BackgroundImageAsset = image
end

function Library:SetLogo(image: string)
	assert(type(image) == "string", "SetLogo requires an asset id string")
	self.LogoImage = image
	if self.BrandLogo then self.BrandLogo.Image = image end
end

function Library:SetIcon(image: string)
	return self:SetLogo(image)
end

function Library:SetHubVisible(visible: boolean)
	if self.Destroyed or not self.Window or not self.WindowGroup then return end
	visible = visible == true
	if self.HubVisible == visible and self.WindowGroup.Visible == visible then return end
	self.HubVisible = visible
	if visible then
		self.WindowGroup.Visible = true
		self.Window.Visible = true
		self.WindowGroup.GroupTransparency = 1
		if self.WindowScale then
			self.WindowScale.Scale = 0.96
			tween(self.WindowScale, 0.24, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
		tween(self.WindowGroup, 0.24, {GroupTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	else
		if self.ActiveDropdown then self.ActiveDropdown:Close() end
		if self.ActiveColorPicker and self.ActiveColorPicker.Popup then
			self.ActiveColorPicker.Popup.Visible = false
			self.ActiveColorPicker = nil
		end
		if self.WindowScale then
			tween(self.WindowScale, 0.2, {Scale = 0.96}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		end
		tween(self.WindowGroup, 0.2, {GroupTransparency = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.2, function()
			if not self.Destroyed and not self.HubVisible then self.WindowGroup.Visible = false end
		end)
	end
end

function Library:ToggleHub()
	self:SetHubVisible(not self.HubVisible)
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
	local label = text(button, config.Name, 12, self.Theme.TextMuted, Enum.Font.GothamBold)
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
	padding(page, 16, 16, 16, 12)

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
	self.WindowGroup.Visible = true
	self.WindowGroup.GroupTransparency = 1
	self.BackgroundImage.Visible = self.ShowBackground
	self.GlassWash.Visible = self.ShowBackground
	-- The shadow uses a different aspect ratio than the responsive window and
	-- can spill below it. Keep the panel edge clean at every size.
	self.AmbientShadow.Visible = false
	-- Keep the frame itself transparent so the 78664802433772 backdrop can
	-- show through the glass surfaces and content cards.
	self.Window.BackgroundTransparency = 1

	local windowScale = self.WindowScale
	if not windowScale then
		windowScale = Instance.new("UIScale")
		windowScale.Parent = self.Window
		self.WindowScale = windowScale
	end
	windowScale.Scale = 0.16
	tween(windowScale, 0.78, {Scale = 1}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	tween(self.WindowGroup, 0.68, {GroupTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
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
	if self.WindowDragConnection then
		self.WindowDragConnection:Disconnect()
		self.WindowDragConnection = nil
	end
	if self.ColorPickerDragConnections then
		for _, connection in ipairs(self.ColorPickerDragConnections) do
			connection:Disconnect()
		end
		table.clear(self.ColorPickerDragConnections)
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
	local matches = {}
	local sectionMatches = {}
	for _, entry in ipairs(self.SearchEntries) do
		local matched = query == "" or string.find(entry.SearchText, query, 1, true) ~= nil
		entry.Row.Visible = matched
		if matched then
			table.insert(matches, entry)
			firstMatchTab = firstMatchTab or entry.Tab
		end
		sectionMatches[entry.Section] = sectionMatches[entry.Section] or false
		if matched then sectionMatches[entry.Section] = true end
	end
	for section, matches in pairs(sectionMatches) do
		section.Visible = matches or query == ""
	end
	if self.SearchResultTab then
		self.SearchResultTab.NavButton.Visible = query ~= ""
		self.SearchResultDescription.Text = query == "" and "Search settings from the tabs area." or ("Results for: \"" .. queryValue .. "\"")
		self:_refreshSearchResults(matches)
		if query ~= "" then
			if self.ActiveTab ~= self.SearchResultTab then self:SelectTab(self.SearchResultTab) end
		elseif self.ActiveTab == self.SearchResultTab and self.Tabs[1] then
			self:SelectTab(self.Tabs[1])
		end
	elseif query ~= "" and firstMatchTab and self.ActiveTab ~= firstMatchTab then
		self:SelectTab(firstMatchTab)
	end
end

function Library:_controlRow(parent: Instance, titleValue: string, descriptionValue: string?)
	local library = self.Library or self
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, descriptionValue and 60 or 44)
	row.BackgroundColor3 = self.Theme.Surface
	row.BackgroundTransparency = 0.62
	row.BorderSizePixel = 0
	row.Parent = parent
	corner(row, 6)
	stroke(row, self.Theme.StrokeSoft, 0.72)
	hover(row, self.Theme.Surface, self.Theme.SurfaceHover)
	local titleLabel = text(row, titleValue, 11, self.Theme.Text, Enum.Font.GothamMedium)
	titleLabel.Position = UDim2.fromOffset(16, descriptionValue and 11 or 0)
	titleLabel.Size = UDim2.fromOffset(0, 20)
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	if descriptionValue then
	local descriptionLabel = text(row, descriptionValue, 9, self.Theme.TextMuted, Enum.Font.GothamMedium)
		descriptionLabel.Position = UDim2.fromOffset(16, 31)
		descriptionLabel.Size = UDim2.fromOffset(0, 18)
		descriptionLabel.TextTransparency = 0.08
		descriptionLabel.TextWrapped = false
		descriptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
	end
	local function updateLabelWidths()
		local available = math.max(0, row.AbsoluteSize.X - 160)
		titleLabel.Size = UDim2.fromOffset(available, 20)
		if descriptionValue then
			local descriptionLabel = row:FindFirstChildWhichIsA("TextLabel")
			if descriptionLabel and descriptionLabel ~= titleLabel then descriptionLabel.Size = UDim2.fromOffset(available, 18) end
		end
	end
	row:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLabelWidths)
	updateLabelWidths()
	library.SearchEntries = library.SearchEntries or {}
	table.insert(library.SearchEntries, {
		Row = row,
		Section = self.Root,
		Tab = self.Tab,
		Title = titleValue,
		Description = descriptionValue or "",
		SearchText = string.lower(titleValue .. " " .. (descriptionValue or "")),
	})
	if self.Rows then table.insert(self.Rows, row) end
	return row
end

function Library:_registerFlagControl(flag: string, setter: (...any) -> ())
	self.FlagControls = self.FlagControls or {}
	self.FlagControls[flag] = setter
end

function Library:_refreshSearchResults(entries: {any})
	if not self.SearchResultsList or not self.SearchResultsEmpty then return end
	for _, child in ipairs(self.SearchResultsList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	self.SearchResultsEmpty.Visible = #entries == 0
	for _, entry in ipairs(entries) do
		local result = Instance.new("TextButton")
		result.Name = entry.Title .. "Result"
		result.AutoButtonColor = false
		result.Text = ""
		result.Size = UDim2.new(1, 0, 0, 52)
		result.BackgroundColor3 = self.Theme.Surface
		result.BackgroundTransparency = 0.42
		result.BorderSizePixel = 0
		result.Parent = self.SearchResultsList
		corner(result, 9)
		stroke(result, self.Theme.StrokeSoft, 0.48)
		local title = text(result, entry.Title, 11, self.Theme.Text, Enum.Font.GothamMedium)
		title.Position = UDim2.fromOffset(14, 4)
		title.Size = UDim2.new(1, -130, 0, 22)
		local location = text(result, entry.Tab.Name, 9, self.Theme.AccentBright, Enum.Font.GothamBold)
		location.Position = UDim2.new(1, -112, 0, 4)
		location.Size = UDim2.fromOffset(98, 22)
		location.TextXAlignment = Enum.TextXAlignment.Right
		local description = text(result, entry.Description, 9, self.Theme.TextMuted, Enum.Font.Gotham)
		description.Position = UDim2.fromOffset(14, 27)
		description.Size = UDim2.new(1, -28, 0, 18)
		description.TextTruncate = Enum.TextTruncate.AtEnd
		hover(result, self.Theme.Surface, self.Theme.StrokeSoft)
		result.MouseButton1Click:Connect(function()
			self.SearchBox.Text = ""
			self:SelectTab(entry.Tab)
		end)
	end
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

function Library:TextBox(config: {[string]: any})
	local row = self:_controlRow(self.Container, config.Name or "Text input", config.Description)
	row.Size = UDim2.new(1, 0, 0, config.Description and 64 or 50)
	local input = Instance.new("TextBox")
	input.Name = "Input"
	input.ClearTextOnFocus = false
	input.Text = tostring(config.Default or "")
	input.PlaceholderText = config.Placeholder or "Enter text..."
	input.PlaceholderColor3 = self.Theme.TextMuted
	input.TextColor3 = self.Theme.Text
	input.TextSize = 10
	input.Font = Enum.Font.GothamSemibold
	input.TextXAlignment = Enum.TextXAlignment.Left
	input.TextWrapped = false
	input.TextTruncate = Enum.TextTruncate.AtEnd
	input.BackgroundColor3 = self.Theme.StrokeSoft
	input.BackgroundTransparency = 0.28
	input.BorderSizePixel = 0
	input.AnchorPoint = Vector2.new(1, 0.5)
	input.Position = UDim2.new(1, -14, 0.5, 0)
	input.Size = UDim2.fromOffset(config.Width or 142, 29)
	input.Parent = row
	corner(input, 8)
	local inputStroke = stroke(input, self.Theme.AccentDeep, 0.35)
	padding(input, 10, 10, 0, 0)
	input.Focused:Connect(function()
		tween(input, 0.16, {BackgroundTransparency = 0.12})
		tween(inputStroke, 0.16, {Transparency = 0.05, Color = self.Theme.Accent})
	end)
	input.FocusLost:Connect(function()
		tween(input, 0.16, {BackgroundTransparency = 0.28})
		tween(inputStroke, 0.16, {Transparency = 0.35, Color = self.Theme.AccentDeep})
	end)
	local value = input.Text
	local function set(nextValue: string, silent: boolean?)
		value = tostring(nextValue or "")
		input.Text = value
		self.Flags[config.Flag or config.Name or "TextBox"] = value
		if not silent and config.Callback then
			local success, errorMessage = pcall(config.Callback, value)
			if not success then warn("ClappedHub text callback failed:", errorMessage) end
		end
	end
	input.FocusLost:Connect(function()
		set(input.Text)
	end)
	if config.Live then
		input:GetPropertyChangedSignal("Text"):Connect(function() set(input.Text) end)
	end
	set(value, true)
	local control = {Row = row, Input = input, Set = set, Get = function() return value end}
	(self.Library or self):_registerFlagControl(config.Flag or config.Name or "TextBox", set)
	return control
end

function Library:Dropdown(config: {[string]: any})
	local library = self.Library or self
	local options = config.Options or {}
	local row = self:_controlRow(self.Container, config.Name or "Dropdown", config.Description)
	local value = tostring(config.Default or options[1] or "None")
	local button = Instance.new("TextButton")
	button.Name = "DropdownButton"
	button.AutoButtonColor = false
	button.Text = value
	button.TextSize = 12
	button.Font = Enum.Font.GothamBold
	button.TextXAlignment = Enum.TextXAlignment.Center
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.TextWrapped = false
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextTransparency = 0
	button.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	button.TextStrokeTransparency = 0
	button.BackgroundColor3 = self.Theme.StrokeSoft
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.Size = UDim2.fromOffset(config.Width or 136, 30)
	button.Parent = row
	corner(button, 8)
	local dropdownStroke = stroke(button, self.Theme.AccentDeep, 0.24, 1.15)
	local dropdownGradient = Instance.new("UIGradient")
	dropdownGradient.Color = ColorSequence.new(self.Theme.SurfaceRaised, self.Theme.StrokeSoft)
	dropdownGradient.Rotation = 90
	dropdownGradient.Parent = button
	button.MouseEnter:Connect(function()
		tween(dropdownStroke, 0.16, {Transparency = 0.04, Color = self.Theme.Accent})
	end)
	button.MouseLeave:Connect(function()
		tween(dropdownStroke, 0.2, {Transparency = 0.24, Color = self.Theme.AccentDeep})
	end)
	hover(button, self.Theme.StrokeSoft, self.Theme.AccentDeep)
	local menu = Instance.new("Frame")
	menu.Name = "DropdownMenu"
	menu.BackgroundColor3 = library.Theme.Window
	menu.BackgroundTransparency = 0.08
	menu.BorderSizePixel = 0
	menu.Visible = false
	menu.ZIndex = 50
	menu.Parent = library.Gui
	corner(menu, 10)
	stroke(menu, library.Theme.Stroke, 0.22)
	local menuList = Instance.new("UIListLayout")
	menuList.Padding = UDim.new(0, 4)
	menuList.Parent = menu
	padding(menu, 7, 7, 7, 7)
	local dropdown = {Row = row, Button = button, Menu = menu}
	local function closeMenu()
		menu.Visible = false
		if library.ActiveDropdown == dropdown then library.ActiveDropdown = nil end
	end
	local function positionMenu()
		local camera = workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
		local width = 180
		local height = math.min(190, 14 + (#options * 30))
		local x = math.clamp(row.AbsolutePosition.X + row.AbsoluteSize.X - width, 8, math.max(8, viewport.X - width - 8))
		local y = row.AbsolutePosition.Y + row.AbsoluteSize.Y + 6
		if y + height > viewport.Y - 8 then y = math.max(8, row.AbsolutePosition.Y - height - 6) end
		menu.Size = UDim2.fromOffset(width, height)
		menu.Position = UDim2.fromOffset(x, y)
	end
	local function set(nextValue: string, silent: boolean?)
		value = tostring(nextValue or "None")
		button.Text = value
		library.Flags[config.Flag or config.Name or "Dropdown"] = value
		if not silent and config.Callback then
			local success, errorMessage = pcall(config.Callback, value)
			if not success then warn("ClappedHub dropdown callback failed:", errorMessage) end
		end
	end
	for _, option in ipairs(options) do
		local optionButton = Instance.new("TextButton")
		optionButton.Name = tostring(option) .. "Option"
		optionButton.AutoButtonColor = false
		optionButton.Text = tostring(option)
		optionButton.TextSize = 12
		optionButton.Font = Enum.Font.GothamBold
		optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		optionButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		optionButton.TextStrokeTransparency = 0.25
		optionButton.BackgroundColor3 = library.Theme.Surface
		optionButton.BackgroundTransparency = 0.25
		optionButton.BorderSizePixel = 0
		optionButton.Size = UDim2.new(1, 0, 0, 26)
		optionButton.Parent = menu
		corner(optionButton, 7)
		hover(optionButton, library.Theme.Surface, library.Theme.StrokeSoft)
		optionButton.MouseButton1Click:Connect(function()
			set(tostring(option))
			closeMenu()
		end)
	end
	button.MouseButton1Click:Connect(function()
		if menu.Visible then closeMenu() return end
		if library.ActiveDropdown and library.ActiveDropdown ~= dropdown then library.ActiveDropdown:Close() end
		if library.ActiveColorPicker and library.ActiveColorPicker.Popup then library.ActiveColorPicker.Popup.Visible = false end
		library.ActiveDropdown = dropdown
		positionMenu()
		menu.Visible = true
	end)
	dropdown.Close = closeMenu
	dropdown.Set = set
	dropdown.Get = function() return value end
	set(value, true)
	library:_registerFlagControl(config.Flag or config.Name or "Dropdown", set)
	return dropdown
end

function Library:ColorPicker(config: {[string]: any})
	local library = self.Library or self
	local row = self:_controlRow(self.Container, config.Name or "Color", config.Description)
	row.Size = UDim2.new(1, 0, 0, config.Description and 64 or 50)
	local value = typeof(config.Default) == "Color3" and config.Default or library.Theme.Accent
	local swatch = Instance.new("TextButton")
	swatch.Name = "ColorSwatch"
	swatch.AutoButtonColor = false
	swatch.Text = ""
	swatch.BackgroundColor3 = value
	swatch.BackgroundTransparency = 0.04
	swatch.BorderSizePixel = 0
	swatch.AnchorPoint = Vector2.new(1, 0.5)
	swatch.Position = UDim2.new(1, -14, 0.5, 0)
	swatch.Size = UDim2.fromOffset(64, 29)
	swatch.Parent = row
	corner(swatch, 8)
	stroke(swatch, library.Theme.Text, 0.2)
	local popup = Instance.new("Frame")
	popup.Name = "ColorPickerPopup"
	popup.Size = UDim2.fromOffset(300, 270)
	popup.BackgroundColor3 = library.Theme.Window
	popup.BackgroundTransparency = 1
	popup.BorderSizePixel = 0
	popup.ClipsDescendants = true
	popup.Active = true
	popup.Visible = false
	popup.ZIndex = 50
	popup.Parent = library.Gui
	corner(popup, 16)
	stroke(popup, library.Theme.Stroke, 0.2)
	local background = Instance.new("ImageLabel")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1
	background.Image = library.BackgroundImage.Image
	background.ImageTransparency = 0.12
	background.ScaleType = Enum.ScaleType.Crop
	background.ZIndex = 50
	background.Parent = popup
	corner(background, 16)
	local wash = Instance.new("Frame")
	wash.Size = UDim2.fromScale(1, 1)
	wash.BackgroundColor3 = Color3.fromRGB(8, 16, 30)
	wash.BackgroundTransparency = 0.24
	wash.BorderSizePixel = 0
	wash.ZIndex = 50
	wash.Parent = popup
	corner(wash, 16)
	local hue, saturation, brightness = value:ToHSV()
	local palette = Instance.new("Frame")
	palette.Name = "ColorPalette"
	palette.Position = UDim2.fromOffset(12, 48)
	palette.Size = UDim2.fromOffset(150, 150)
	palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
	palette.BorderSizePixel = 0
	palette.ZIndex = 51
	palette.Parent = popup
	corner(palette, 75)
	local whiteShade = Instance.new("Frame")
	whiteShade.Size = UDim2.fromScale(1, 1)
	whiteShade.BackgroundColor3 = Color3.new(1, 1, 1)
	whiteShade.BackgroundTransparency = 0
	whiteShade.BorderSizePixel = 0
	whiteShade.ZIndex = 52
	whiteShade.Parent = palette
	corner(whiteShade, 75)
	local whiteGradient = Instance.new("UIGradient")
	whiteGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
	whiteGradient.Parent = whiteShade
	local blackShade = Instance.new("Frame")
	blackShade.Size = UDim2.fromScale(1, 1)
	blackShade.BackgroundColor3 = Color3.new(0, 0, 0)
	blackShade.BackgroundTransparency = 0
	blackShade.BorderSizePixel = 0
	blackShade.ZIndex = 53
	blackShade.Parent = palette
	corner(blackShade, 75)
	local blackGradient = Instance.new("UIGradient")
	blackGradient.Rotation = 90
	blackGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
	blackGradient.Parent = blackShade
	local paletteHit = Instance.new("TextButton")
	paletteHit.Name = "PaletteInput"
	paletteHit.Text = ""
	paletteHit.BackgroundTransparency = 1
	paletteHit.BorderSizePixel = 0
	paletteHit.Size = UDim2.fromScale(1, 1)
	paletteHit.ZIndex = 54
	paletteHit.Parent = palette
	local paletteCursor = Instance.new("Frame")
	paletteCursor.Name = "PaletteCursor"
	paletteCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	paletteCursor.Size = UDim2.fromOffset(13, 13)
	paletteCursor.BackgroundTransparency = 1
	paletteCursor.BorderSizePixel = 0
	paletteCursor.ZIndex = 55
	paletteCursor.Parent = palette
	corner(paletteCursor, 7)
	stroke(paletteCursor, library.Theme.Text, 0.08, 1.5)
	local hueBar = Instance.new("Frame")
	hueBar.Name = "HueBar"
	hueBar.Position = UDim2.fromOffset(174, 48)
	hueBar.Size = UDim2.fromOffset(20, 150)
	hueBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	hueBar.BorderSizePixel = 0
	hueBar.ClipsDescendants = true
	hueBar.ZIndex = 51
	hueBar.Parent = popup
	corner(hueBar, 8)
	local hueSegments = 72
	for index = 1, hueSegments do
		local hueSegment = Instance.new("Frame")
		hueSegment.Name = "HueSegment" .. index
		hueSegment.Position = UDim2.fromScale(0, (index - 1) / hueSegments)
		hueSegment.Size = UDim2.fromScale(1, (1 / hueSegments) + 0.004)
		hueSegment.BackgroundColor3 = Color3.fromHSV((index - 1) / (hueSegments - 1), 1, 1)
		hueSegment.BorderSizePixel = 0
		hueSegment.ZIndex = 52
		hueSegment.Parent = hueBar
	end
	local hueHit = Instance.new("TextButton")
	hueHit.Name = "HueInput"
	hueHit.Text = ""
	hueHit.BackgroundTransparency = 1
	hueHit.BorderSizePixel = 0
	hueHit.Size = UDim2.fromScale(1, 1)
	hueHit.ZIndex = 54
	hueHit.Parent = hueBar
	local hueCursor = Instance.new("Frame")
	hueCursor.Name = "HueCursor"
	hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	hueCursor.Position = UDim2.fromOffset(184, 48)
	hueCursor.Size = UDim2.fromOffset(26, 5)
	hueCursor.BackgroundTransparency = 1
	hueCursor.BorderSizePixel = 0
	hueCursor.ZIndex = 55
	hueCursor.Parent = popup
	corner(hueCursor, 3)
	stroke(hueCursor, library.Theme.Text, 0.08, 1.5)
	local popupHeader = Instance.new("Frame")
	popupHeader.Size = UDim2.new(1, 0, 0, 36)
	popupHeader.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
	popupHeader.BackgroundTransparency = 0.3
	popupHeader.BorderSizePixel = 0
	popupHeader.ZIndex = 51
	popupHeader.ClipsDescendants = true
	popupHeader.Active = true
	popupHeader.Parent = popup
	corner(popupHeader, 16)
	local popupTitle = text(popupHeader, "COLOR PICKER", 10, library.Theme.Text, Enum.Font.GothamBold)
	popupTitle.Position = UDim2.fromOffset(12, 0)
	popupTitle.Size = UDim2.new(1, -100, 1, 0)
	popupTitle.ZIndex = 52
	local dragHint = text(popupHeader, "DRAG", 8, library.Theme.TextMuted, Enum.Font.GothamBold)
	dragHint.Position = UDim2.new(1, -70, 0, 0)
	dragHint.Size = UDim2.fromOffset(38, 36)
	dragHint.TextXAlignment = Enum.TextXAlignment.Right
	dragHint.ZIndex = 52
	local popupClose = Instance.new("TextButton")
	popupClose.Text = "×"
	popupClose.TextSize = 16
	popupClose.Font = Enum.Font.GothamMedium
	popupClose.TextColor3 = library.Theme.Text
	popupClose.BackgroundColor3 = library.Theme.StrokeSoft
	popupClose.BackgroundTransparency = 0.12
	popupClose.BorderSizePixel = 0
	popupClose.AnchorPoint = Vector2.new(1, 0.5)
	popupClose.Position = UDim2.new(1, -10, 0.5, 0)
	popupClose.Size = UDim2.fromOffset(26, 24)
	popupClose.ZIndex = 52
	popupClose.Parent = popupHeader
	corner(popupClose, 7)
	hover(popupClose, library.Theme.StrokeSoft, library.Theme.AccentDeep)
	local pickerDragging = false
	local pickerDragStart
	local pickerStartPosition
	local pickerDragInput
	popupHeader.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pickerDragging = true
			pickerDragStart = input.Position
			pickerStartPosition = popup.Position
		end
	end)
	popupHeader.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			pickerDragInput = input
		end
	end)
	table.insert(library.ColorPickerDragConnections, UserInputService.InputChanged:Connect(function(input)
		if not pickerDragging or (input ~= pickerDragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement) then return end
		local delta = input.Position - pickerDragStart
		popup.Position = UDim2.new(
			pickerStartPosition.X.Scale,
			pickerStartPosition.X.Offset + delta.X,
			pickerStartPosition.Y.Scale,
			pickerStartPosition.Y.Offset + delta.Y
		)
	end))
	table.insert(library.ColorPickerDragConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			pickerDragging = false
			pickerDragInput = nil
		end
	end))
	local hexInput = Instance.new("TextBox")
	hexInput.Name = "HexInput"
	hexInput.ClearTextOnFocus = false
	hexInput.Text = colorToHex(value)
	hexInput.PlaceholderText = "#RRGGBB"
	hexInput.TextColor3 = library.Theme.Text
	hexInput.PlaceholderColor3 = library.Theme.TextMuted
	hexInput.TextSize = 10
	hexInput.Font = Enum.Font.Gotham
	hexInput.BackgroundColor3 = library.Theme.Surface
	hexInput.BackgroundTransparency = 0.2
	hexInput.BorderSizePixel = 0
	hexInput.Position = UDim2.fromOffset(12, 230)
	hexInput.Size = UDim2.fromOffset(276, 28)
	hexInput.ZIndex = 52
	hexInput.Parent = popup
	corner(hexInput, 8)
	stroke(hexInput, library.Theme.StrokeSoft, 0.25)
	local preview = Instance.new("Frame")
	preview.Name = "Preview"
	preview.BackgroundColor3 = value
	preview.BorderSizePixel = 0
	preview.Position = UDim2.fromOffset(214, 48)
	preview.Size = UDim2.fromOffset(72, 50)
	preview.ZIndex = 51
	preview.Parent = popup
	corner(preview, 9)
	stroke(preview, library.Theme.Text, 0.25)
	local channels = {}
	for index, channel in ipairs({"R", "G", "B"}) do
		local channelLabel = text(popup, channel, 10, library.Theme.AccentBright, Enum.Font.GothamBold)
		channelLabel.Position = UDim2.fromOffset(214, 108 + ((index - 1) * 27))
		channelLabel.Size = UDim2.fromOffset(18, 28)
		channelLabel.ZIndex = 52
		local channelInput = Instance.new("TextBox")
		channelInput.Name = channel .. "Input"
		channelInput.ClearTextOnFocus = false
		channelInput.Text = "0"
		channelInput.TextColor3 = library.Theme.Text
		channelInput.TextSize = 10
		channelInput.Font = Enum.Font.Gotham
		channelInput.BackgroundColor3 = library.Theme.Surface
		channelInput.BackgroundTransparency = 0.2
		channelInput.BorderSizePixel = 0
		channelInput.Position = UDim2.fromOffset(232, 108 + ((index - 1) * 27))
		channelInput.Size = UDim2.fromOffset(54, 25)
		channelInput.ZIndex = 52
		channelInput.Parent = popup
		corner(channelInput, 7)
		stroke(channelInput, library.Theme.StrokeSoft, 0.25)
		channels[channel] = channelInput
	end
	local picker = {Row = row, Button = swatch, Popup = popup}
	local function clampPalettePoint(percentX: number, percentY: number)
		local offsetX = percentX - 0.5
		local offsetY = percentY - 0.5
		local distance = math.sqrt((offsetX * offsetX) + (offsetY * offsetY))
		local paletteDiameter = palette.AbsoluteSize.X > 0 and palette.AbsoluteSize.X or 150
		local cursorDiameter = paletteCursor.AbsoluteSize.X > 0 and paletteCursor.AbsoluteSize.X or 13
		local radius = math.max(0, 0.5 - ((cursorDiameter / paletteDiameter) / 2))
		if distance > radius and distance > 0 then
			local scale = radius / distance
			offsetX *= scale
			offsetY *= scale
		end
		return math.clamp(offsetX + 0.5, 0, 1), math.clamp(offsetY + 0.5, 0, 1)
	end
	local function refreshFields()
		local red, green, blue = math.floor(value.R * 255 + 0.5), math.floor(value.G * 255 + 0.5), math.floor(value.B * 255 + 0.5)
		hue, saturation, brightness = value:ToHSV()
		hexInput.Text = colorToHex(value)
		channels.R.Text, channels.G.Text, channels.B.Text = tostring(red), tostring(green), tostring(blue)
		swatch.BackgroundColor3 = value
		preview.BackgroundColor3 = value
		palette.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		local cursorX, cursorY = clampPalettePoint(saturation, 1 - brightness)
		paletteCursor.Position = UDim2.fromScale(cursorX, cursorY)
		hueCursor.Position = UDim2.fromOffset(184, 48 + (hue * 150))
	end
	local function set(nextValue: Color3, silent: boolean?)
		value = nextValue
		library.Flags[config.Flag or config.Name or "ColorPicker"] = value
		refreshFields()
		if not silent and config.Callback then
			local success, errorMessage = pcall(config.Callback, value)
			if not success then warn("ClappedHub color callback failed:", errorMessage) end
		end
	end
	local function applyChannels()
		local red = math.clamp(tonumber(channels.R.Text) or 0, 0, 255)
		local green = math.clamp(tonumber(channels.G.Text) or 0, 0, 255)
		local blue = math.clamp(tonumber(channels.B.Text) or 0, 0, 255)
		set(Color3.fromRGB(red, green, blue))
	end
	hexInput.FocusLost:Connect(function() set(colorFromHex(hexInput.Text) or value) end)
	for _, channelInput in pairs(channels) do channelInput.FocusLost:Connect(applyChannels) end
	local paletteDragging = false
	local hueDragging = false
	local function updatePalette(input: any)
		local percentX = math.clamp((input.Position.X - palette.AbsolutePosition.X) / palette.AbsoluteSize.X, 0, 1)
		local percentY = math.clamp((input.Position.Y - palette.AbsolutePosition.Y) / palette.AbsoluteSize.Y, 0, 1)
		percentX, percentY = clampPalettePoint(percentX, percentY)
		set(Color3.fromHSV(hue, percentX, 1 - percentY))
	end
	local function updateHue(input: any)
		local percentY = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
		hue = percentY
		set(Color3.fromHSV(hue, saturation, brightness))
	end
	paletteHit.MouseButton1Down:Connect(function()
		paletteDragging = true
		updatePalette({Position = UserInputService:GetMouseLocation()})
	end)
	hueHit.MouseButton1Down:Connect(function()
		hueDragging = true
		updateHue({Position = UserInputService:GetMouseLocation()})
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		if paletteDragging then updatePalette(input) end
		if hueDragging then updateHue(input) end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			paletteDragging = false
			hueDragging = false
		end
	end)
	local function positionPopup()
		local camera = workspace.CurrentCamera
		local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
		local width, height = 300, 270
		local x = math.clamp(row.AbsolutePosition.X + row.AbsoluteSize.X - width, 8, math.max(8, viewport.X - width - 8))
		local y = row.AbsolutePosition.Y + row.AbsoluteSize.Y + 6
		if y + height > viewport.Y - 8 then y = math.max(8, row.AbsolutePosition.Y - height - 6) end
		popup.Position = UDim2.fromOffset(x, y)
	end
	swatch.MouseButton1Click:Connect(function()
		if popup.Visible then popup.Visible = false; library.ActiveColorPicker = nil; return end
		if library.ActiveDropdown then library.ActiveDropdown:Close() end
		if library.ActiveColorPicker and library.ActiveColorPicker.Popup then library.ActiveColorPicker.Popup.Visible = false end
		library.ActiveColorPicker = picker
		positionPopup()
		popup.Visible = true
	end)
	popupClose.MouseButton1Click:Connect(function() popup.Visible = false; library.ActiveColorPicker = nil end)
	picker.Set = set
	picker.Get = function() return value end
	set(value, true)
	library:_registerFlagControl(config.Flag or config.Name or "ColorPicker", set)
	return picker
end

function Library:Button(config: {[string]: any})
	local row = self:_controlRow(self.Container, config.Name or "Action", config.Description)
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.Text = config.Text or "EXECUTE"
	button.TextSize = 10
	button.Font = Enum.Font.GothamSemibold
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.TextWrapped = false
	button.TextColor3 = self.Theme.Text
	button.BackgroundColor3 = self.Theme.AccentDeep
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 0
	button.AnchorPoint = Vector2.new(1, 0.5)
	button.Position = UDim2.new(1, -14, 0.5, 0)
	button.Size = UDim2.fromOffset(config.Width or 112, 32)
	button.Parent = row
	corner(button, 9)
	local buttonStroke = stroke(button, self.Theme.AccentBright, 0.68, 1)
	local buttonGradient = Instance.new("UIGradient")
	buttonGradient.Color = ColorSequence.new(self.Theme.Accent, self.Theme.AccentDeep)
	buttonGradient.Rotation = 90
	buttonGradient.Parent = button
	button.MouseEnter:Connect(function()
		tween(buttonStroke, 0.16, {Transparency = 0.28})
	end)
	button.MouseLeave:Connect(function()
		tween(buttonStroke, 0.2, {Transparency = 0.68})
	end)
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
	local control = {Row = row, Toggle = toggle, Set = set, Get = function() return value end}
	(self.Library or self):_registerFlagControl(config.Flag or config.Name or "Toggle", set)
	return control
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
	library:_registerFlagControl(identifier, function(nextValue: any, silent: boolean?)
		bind:SetEnabled(nextValue == true, silent)
	end)
	if library.KeybindPanel then library:_refreshKeybindPanel() end
	return bind
end

function Library:HubToggleKeybind(config: {[string]: any})
	config = config or {}
	local library = self.Library or self
	local callback = config.Callback
	local bindConfig = table.clone(config)
	bindConfig.Name = config.Name or "Toggle hub"
	bindConfig.Description = config.Description or "Press this key to show or hide the hub."
	bindConfig.Mode = "Toggle"
	bindConfig.DefaultEnabled = false
	bindConfig.Callback = function(enabled: boolean)
		library:SetHubVisible(not enabled)
		if callback then
			local success, errorMessage = pcall(callback, not enabled)
			if not success then warn("ClappedHub hub toggle callback failed:", errorMessage) end
		end
	end
	local bind = self:Keybind(bindConfig)
	library.HubToggleBind = bind
	return bind
end

Library.ToggleHubKeybind = Library.HubToggleKeybind

function Library:ConfigManager(options: {[string]: any}?)
	options = options or {}
	local library = self.Library or self
	local function safeName(value: any, fallback: string): string
		local result = string.gsub(tostring(value or fallback), "[^%w%._%-]", "_")
		return result ~= "" and result or fallback
	end
	local folder = safeName(options.Folder, safeName(library.Name, "ClappedHub"))
	local extension = tostring(options.Extension or ".json")
	if string.sub(extension, 1, 1) ~= "." then extension = "." .. extension end
	local manager = {
		Library = library,
		Folder = folder,
		Extension = extension,
		DefaultConfig = options.DefaultConfig or "Default",
		OnStatus = options.OnStatus,
		LastError = nil,
	}

	local function report(success: boolean, message: string)
		manager.LastError = success and nil or message
		if manager.OnStatus then
			local callbackSuccess, callbackError = pcall(manager.OnStatus, success, message)
			if not callbackSuccess then warn("ClappedHub config status callback failed:", callbackError) end
		end
		return success, message
	end
	local function available()
		return type(writefile) == "function" and type(readfile) == "function" and type(makefolder) == "function"
	end
	local function ensureFolder()
		if not available() then return report(false, "Config storage requires writefile, readfile, and makefolder.") end
		local exists = false
		if type(isfolder) == "function" then
			local ok, result = pcall(isfolder, folder)
			exists = ok and result == true
		end
		if not exists then
			local ok = pcall(makefolder, folder)
			if not ok and type(isfolder) == "function" then
				local checkOk, checkResult = pcall(isfolder, folder)
				if not checkOk or checkResult ~= true then return report(false, "Could not create config folder: " .. folder) end
			end
		end
		return true, "Config folder ready."
	end
	local function path(name: any): string
		return folder .. "/" .. safeName(name, manager.DefaultConfig) .. manager.Extension
	end
	local extensionPattern = string.gsub(manager.Extension, "([^%w])", "%%%1")
	local function encodeValue(value: any, depth: number?): any
		depth = depth or 0
		if depth > 8 then return nil end
		if typeof(value) == "Color3" then
			return {__type = "Color3", R = value.R, G = value.G, B = value.B}
		end
		if type(value) == "string" or type(value) == "number" or type(value) == "boolean" then return value end
		if type(value) == "table" then
			local result = {}
			for key, item in pairs(value) do
				local encoded = encodeValue(item, depth + 1)
				if encoded ~= nil and (type(key) == "string" or type(key) == "number") then result[key] = encoded end
			end
			return result
		end
		return nil
	end
	local function decodeValue(value: any): any
		if type(value) ~= "table" then return value end
		if value.__type == "Color3" then
			return Color3.new(math.clamp(tonumber(value.R) or 0, 0, 1), math.clamp(tonumber(value.G) or 0, 0, 1), math.clamp(tonumber(value.B) or 0, 0, 1))
		end
		local result = {}
		for key, item in pairs(value) do result[key] = decodeValue(item) end
		return result
	end

	function manager:GetPath(name: any): string
		return path(name)
	end
	function manager:Exists(name: any): boolean
		if type(isfile) ~= "function" then return false end
		local ok, result = pcall(isfile, path(name))
		return ok and result == true
	end
	function manager:Save(name: any)
		local folderReady = ensureFolder()
		if not folderReady then return false, manager.LastError end
		local data = {
			Version = 1,
			Flags = {},
			Keybinds = {},
			HubVisible = library.HubVisible,
			KeybindPanelVisible = library.KeybindPanel and library.KeybindPanel.Visible or false,
		}
		for flag, value in pairs(library.Flags) do data.Flags[flag] = encodeValue(value) end
		for identifier, bind in pairs(library.Keybinds) do
			data.Keybinds[identifier] = {
				Key = bind.Key and bind.Key.Name or "Unknown",
				Mode = bind.Mode,
				Enabled = bind.Enabled == true,
			}
		end
		local success, encoded = pcall(function() return HttpService:JSONEncode(data) end)
		if not success then return report(false, "Could not encode config: " .. tostring(encoded)) end
		local writeSuccess, writeError = pcall(writefile, path(name), encoded)
		if not writeSuccess then return report(false, "Could not save config: " .. tostring(writeError)) end
		return report(true, "Saved config: " .. safeName(name, manager.DefaultConfig))
	end
	function manager:Load(name: any)
		if type(readfile) ~= "function" then return report(false, "Config storage requires readfile.") end
		local filePath = path(name)
		if type(isfile) == "function" then
			local existsOk, existsResult = pcall(isfile, filePath)
			if not existsOk or existsResult ~= true then return report(false, "Config does not exist: " .. safeName(name, manager.DefaultConfig)) end
		end
		local readSuccess, contents = pcall(readfile, filePath)
		if not readSuccess then return report(false, "Could not read config: " .. tostring(contents)) end
		local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(contents) end)
		if not decodeSuccess or type(data) ~= "table" then return report(false, "Config contains invalid JSON.") end
		for flag, value in pairs(data.Flags or {}) do
			local decoded = decodeValue(value)
			local setter = library.FlagControls and library.FlagControls[flag]
			if setter then
				local setSuccess, setError = pcall(setter, decoded, true)
				if not setSuccess then warn("ClappedHub config control restore failed:", flag, setError) end
			else
				library.Flags[flag] = decoded
			end
		end
		for identifier, state in pairs(data.Keybinds or {}) do
			local bind = library.Keybinds[identifier]
			if bind and type(state) == "table" then
				if state.Key then bind:SetKey(state.Key) end
				if state.Mode == "Hold" or state.Mode == "Toggle" then bind.Mode = state.Mode end
				bind:SetEnabled(state.Enabled == true, true)
			end
		end
		if data.HubVisible ~= nil then library:SetHubVisible(data.HubVisible == true) end
		if data.KeybindPanelVisible ~= nil then library:SetKeybindPanelVisible(data.KeybindPanelVisible == true) end
		if library.KeybindPanel then library:_refreshKeybindPanel() end
		return report(true, "Loaded config: " .. safeName(name, manager.DefaultConfig))
	end
	function manager:Delete(name: any)
		if type(delfile) ~= "function" then return report(false, "Config storage requires delfile.") end
		if type(isfile) == "function" and not self:Exists(name) then return report(false, "Config does not exist: " .. safeName(name, manager.DefaultConfig)) end
		local success, deleteError = pcall(delfile, path(name))
		if not success then return report(false, "Could not delete config: " .. tostring(deleteError)) end
		return report(true, "Deleted config: " .. safeName(name, manager.DefaultConfig))
	end
	function manager:List(): {string}
		local result = {}
		if type(listfiles) ~= "function" then return result end
		local success, files = pcall(listfiles, folder)
		if not success or type(files) ~= "table" then return result end
		for _, file in ipairs(files) do
			local configName = string.match(tostring(file), "([^/\\]+)" .. extensionPattern .. "$")
			if configName then table.insert(result, configName) end
		end
		table.sort(result)
		return result
	end
	manager.SaveConfig = manager.Save
	manager.LoadConfig = manager.Load
	manager.DeleteConfig = manager.Delete
	library.ConfigManagerObject = manager
	return manager
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
	corner(panel, 20)
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
	corner(background, 20)
	local wash = Instance.new("Frame")
	wash.Name = "KeybindWash"
	wash.Size = UDim2.fromScale(1, 1)
	wash.BackgroundColor3 = Color3.fromRGB(8, 16, 30)
	wash.BackgroundTransparency = 0.3
	wash.BorderSizePixel = 0
	wash.ZIndex = 20
	wash.Parent = panel
	corner(wash, 20)
	local header = Instance.new("Frame")
	header.Name = "KeybindHeader"
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = Color3.fromRGB(4, 8, 16)
	header.BackgroundTransparency = 0.34
	header.BorderSizePixel = 0
	header.ZIndex = 21
	header.ClipsDescendants = true
	header.Parent = panel
	corner(header, 20)
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
	local control = {Row = row, Track = track, Set = set, Get = function() return value end}
	(self.Library or self):_registerFlagControl(config.Flag or config.Name or "Slider", set)
	return control
end

return Library
