# Ocean UI Lib by Fade

Ocean UI Lib is a polished, customizable Luau interface library for Roblox panels, script hubs, dashboards, settings menus, and product showcases.

It gives you a complete visual foundation—window chrome, navigation, controls, notifications, keybinds, themes, and configuration storage—while leaving your actual game or product logic inside your callbacks.

> **Important:** Ocean UI Lib is UI-only. It does not include gameplay automation, remote-event calls, or game-specific behavior.

## Why use Ocean UI Lib?

Building a professional interface from scratch takes time. Ocean UI Lib handles the repetitive UI work so you can focus on your product:

- Consistent spacing, typography, borders, and colors.
- Smooth window, sidebar, notification, and hover animations.
- A simple tab → section → control construction pattern.
- Built-in search, keybind management, and configuration persistence.
- Runtime customization for branding, colors, backgrounds, and visibility.
- Sensible defaults with optional overrides when you need more control.

## Requirements

- Roblox client-side Luau environment.
- A loader capable of fetching and compiling the hosted source.
- A client context for input-driven features such as dragging and keybinds.
- File APIs are recommended for configuration saving, but the library safely reports when they are unavailable.

## Quick start

Use a stable raw URL for your release. During development, add a cache-busting query or pin to a commit.

```lua
local source = game:HttpGet("YOUR_RAW_URL/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not load Ocean UI Lib")()

local UI = Library.new({
    Name = "MY PRODUCT",
    Subtitle = "POWERED BY OCEAN UI",
    EnableLoadingMusic = false,
})

local tab = UI:Tab({
    Name = "Home",
    Icon = "⌂",
    Description = "Your main product page.",
})

local section = UI:Section({
    Tab = tab,
    Name = "Welcome",
    Description = "A short introduction for your users.",
})

section:Button({
    Name = "Test notification",
    Text = "TEST",
    Callback = function()
        UI:Notify({
            Title = "It works",
            Content = "Your callback ran successfully.",
            Icon = "✓",
            Duration = 3,
        })
    end,
})
```

## Recommended construction pattern

Create the library first, then create tabs, sections, and controls in that order.

```text
Library.new(options)
└── UI:Tab(options)
    └── UI:Section({Tab = tab, ...})
        ├── section:Label(options)
        ├── section:Button(options)
        ├── section:Toggle(options)
        └── section:Slider(options)
```

Create all tabs before adding controls when possible. The built-in search indexes control names and descriptions, so use useful words such as `notifications`, `movement`, `appearance`, or `configuration`.

## Constructor options

All constructor options are optional.

| Option | Type | Description |
| --- | --- | --- |
| `Name` | string | Main window title. |
| `Subtitle` | string | Smaller text below the title. |
| `ProfileUserName` | string | Profile-card username; defaults to the local player. |
| `ScriptType` | `"FREE"` or `"PAID"` | Text shown in the profile badge. |
| `Accent` | Color3 | Primary highlight and action color. |
| `Theme` | table | Overrides named theme colors. |
| `IconImage` | string | Main logo asset ID. `Icon` and `LogoImage` are aliases. |
| `BackgroundImage` | string | Background image asset ID. |
| `BackgroundImageTransparency` | number | Background transparency from `0` to `1`. |
| `ShowBackground` | boolean | Shows or hides the glass background. |
| `WindowSize` | Vector2 or UDim2 | Initial window size. |
| `WindowPosition` | UDim2 | Initial window position. |
| `WindowMinSize` | Vector2 | Minimum resizable size. |
| `WindowMaxSize` | Vector2 | Maximum resizable size. |
| `AspectRatio` | number | Optional responsive aspect ratio. |
| `EnableDragging` | boolean | Allows dragging from the header. |
| `EnableMinimize` | boolean | Shows the minimize/restore control. |
| `CollapsibleSidebar` | boolean | Enables manual sidebar collapsing. |
| `AutoCollapseSidebar` | boolean | Collapses the sidebar when the pointer leaves it. |
| `SidebarExpandedWidth` | number | Expanded sidebar width in pixels. |
| `SidebarCollapsedWidth` | number | Collapsed sidebar width in pixels. |
| `SidebarCollapseDelay` | number | Auto-collapse delay in seconds. |
| `ShowSearch` | boolean | Shows the search bar. |
| `ShowProfile` | boolean | Shows the profile card. |
| `EnableLoadingMusic` | boolean | Enables the optional loading transition/music. |

### Production setup

```lua
local UI = Library.new({
    Name = "OCEAN UI LIB",
    Subtitle = "SHOWCASE BY FADE",
    IconImage = "rbxassetid://1234567890",
    Accent = Color3.fromRGB(80, 175, 255),
    WindowSize = Vector2.new(820, 650),
    WindowMinSize = Vector2.new(500, 440),
    WindowMaxSize = Vector2.new(1000, 820),
    ShowSearch = true,
    ShowProfile = true,
    ShowBackground = true,
    EnableDragging = true,
    EnableMinimize = true,
    EnableLoadingMusic = false,
})
```

For a permanently expanded sidebar, use:

```lua
CollapsibleSidebar = false,
AutoCollapseSidebar = false,
```

## Theme customization

Supported theme keys:

`Background`, `Window`, `Sidebar`, `Surface`, `SurfaceRaised`, `SurfaceHover`, `Stroke`, `StrokeSoft`, `Text`, `TextMuted`, `TextFaint`, `Accent`, `AccentBright`, `AccentDeep`, `Success`, `Warning`, `Danger`.

```lua
local UI = Library.new({
    Accent = Color3.fromRGB(90, 190, 255),
    Theme = {
        Background = Color3.fromRGB(7, 10, 18),
        Window = Color3.fromRGB(13, 17, 28),
        Sidebar = Color3.fromRGB(10, 14, 24),
        Surface = Color3.fromRGB(22, 29, 44),
        SurfaceRaised = Color3.fromRGB(35, 46, 68),
        SurfaceHover = Color3.fromRGB(49, 66, 95),
        Text = Color3.fromRGB(244, 248, 255),
        TextMuted = Color3.fromRGB(163, 180, 208),
    },
})
```

You can also change the presentation after creation:

```lua
UI:SetTheme({
    Surface = Color3.fromRGB(24, 30, 45),
    TextMuted = Color3.fromRGB(170, 190, 215),
})

UI:SetAccent(Color3.fromRGB(255, 120, 180))
UI:SetIcon("rbxassetid://1234567890")
UI:SetLogo("rbxassetid://1234567890")
UI:SetBackgroundImage("rbxassetid://78664802433772", 0.2)
UI:SetBackgroundVisible(true)
```

## Tabs and sections

```lua
local tab = UI:Tab({
    Name = "Appearance",
    Icon = "✦",
    Description = "Visual preferences and display options.",
})

local section = UI:Section({
    Tab = tab,
    Name = "Theme settings",
    Description = "Controls for your visual preferences.",
})
```

Tabs are searchable and navigation labels use bold typography for readability. Icons can be text glyphs or other supported icon values used by your environment.

## Controls

### Label

Use labels for read-only status or information.

```lua
section:Label({
    Title = "Status",
    Text = "Online",
})
```

### Button

Buttons run a callback when clicked. `Width` and `Height` are optional for longer labels or special layouts.

```lua
local button = section:Button({
    Name = "Run action",
    Text = "RUN",
    Description = "Executes a one-time action.",
    Width = 136,
    Height = 32,
    Callback = function()
        print("Action ran")
    end,
})

button.SetText("READY")
button.SetEnabled(false)
```

### Toggle

Toggles return `Set` and `Get` methods.

```lua
local toggle = section:Toggle({
    Name = "Notifications",
    Flag = "Notifications",
    Default = true,
    Callback = function(enabled)
        print("Notifications:", enabled)
    end,
})

toggle.Set(false)
print(toggle.Get())
```

### Slider

Slider values are clamped between `Min` and `Max`. `Format` controls the displayed value text.

```lua
local slider = section:Slider({
    Name = "Example slider",
    Flag = "ExampleSlider",
    Min = 0,
    Max = 100,
    Default = 75,
    Format = "%d%%",
    Callback = function(value)
        print("Slider value:", value)
    end,
})

slider.Set(50)
print(slider.Get())
```

### Dropdown

Dropdowns support centered, bold option text and a configurable width.

```lua
section:Dropdown({
    Name = "Example dropdown",
    Flag = "ExampleDropdown",
    Width = 160,
    Options = {"First option", "Second option", "Third option"},
    Default = "First option",
    Callback = function(value)
        print("Selected:", value)
    end,
})
```

### TextBox

By default, the callback runs when focus is lost. Set `Live = true` to run it as the text changes.

```lua
local box = section:TextBox({
    Name = "Example text box",
    Description = "A clean padded input field.",
    Flag = "ExampleText",
    Width = 160,
    Placeholder = "Enter text...",
    Default = "Example",
    Live = false,
    Callback = function(value)
        print("Text:", value)
    end,
})

box.Set("Updated value")
print(box.Get())
```

### ColorPicker

The color picker includes a circular saturation/value palette, hue slider, RGB fields, hex input, preview, and a draggable panel.

```lua
local picker = section:ColorPicker({
    Name = "Example color picker",
    Flag = "ExampleColor",
    Default = Color3.fromRGB(80, 175, 255),
    Callback = function(color)
        print("Color:", color)
    end,
})

picker.Set(Color3.fromRGB(255, 120, 180))
print(picker.Get())
```

### Keybind

Use `Toggle` for press-to-switch behavior or `Hold` for behavior active only while held.

```lua
section:Keybind({
    Name = "Example keybind",
    Flag = "ExampleKeybind",
    Key = Enum.KeyCode.RightShift,
    Mode = "Toggle", -- or "Hold"
    Callback = function(enabled)
        print("Keybind state:", enabled)
    end,
})
```

Users can click the displayed key to rebind it. Escape cancels rebinding.

## Notifications

Notifications support any title, body text, optional word/icon label, color, and duration. `Title`, `Content`, and `Icon` are user-provided strings; they are not limited to preset words or checkmarks.

```lua
UI:Notify({
    Title = "Configuration saved",
    Content = "Your preferences were saved successfully.",
    Icon = "✓",
    ShowAccentBar = true,
    Color = Color3.fromRGB(74, 205, 143),
    Duration = 3,
})
```

`ShowAccentBar` controls the colored vertical line on the left side of each notification. It is enabled by default and can be disabled per notification:

```lua
UI:Notify({
    Title = "Minimal notification",
    Content = "This notification has no accent line.",
    ShowAccentBar = false,
})
```

Custom notification text:

```lua
UI:Notify({
    Title = "Custom title written by your script",
    Content = "You can display any message here.",
    Icon = "READY", -- Optional; words and symbols are both supported.
    Color = Color3.fromRGB(80, 175, 255),
    Duration = 4,
})
```

Notifications stack automatically and animate in the lower-right area of the interface.

## Runtime window and visibility controls

```lua
UI:SetWindowSize(Vector2.new(800, 680))
UI:SetWindowPosition(UDim2.fromScale(0.5, 0.46))
UI:SetSearchVisible(false)
UI:SetProfileVisible(true)
UI:SetBackgroundVisible(true)
UI:SetSidebarAutoCollapse(false)
```

`EnableDragging` and `EnableMinimize` are constructor options because they affect the window’s input behavior.

## Keybind panel and hub visibility

```lua
UI:SetKeybindPanelVisible(true)
UI:SetHubVisible(false)
UI:SetHubVisible(true)
UI:ToggleHub()
```

Add built-in controls to a section:

```lua
section:KeybindListToggle({
    Name = "Show keybind panel",
    Default = false,
})

section:HubToggleKeybind({
    Name = "Toggle hub",
    Key = Enum.KeyCode.RightShift,
    Mode = "Toggle",
})
```

`ToggleHubKeybind` is also accepted as an alias for `HubToggleKeybind`.

## Configuration manager

Flags identify values that should be persisted. Give every persistent control a unique flag.

```lua
local configs = UI:ConfigManager({
    Folder = "MyProductConfigs",
    DefaultConfig = "Default",
    OnStatus = function(success, message)
        print(success and "Config OK:" or "Config error:", message)
    end,
})

local saved, saveMessage = configs:Save("Default")
local loaded, loadMessage = configs:Load("Default")
local deleted, deleteMessage = configs:Delete("OldConfig")
local names = configs:List()
```

Available aliases include `SaveConfig`, `LoadConfig`, and `DeleteConfig`. If file APIs are unavailable, operations return `false` and an explanation. Always display that message to the user instead of silently assuming the operation succeeded.

The manager can persist flagged toggles, sliders, dropdowns, text boxes, colors, keybinds, hub visibility, and keybind-panel state.

## Loading transition

Loading music is optional and disabled by default in most product examples.

```lua
local UI = Library.new({
    EnableLoadingMusic = true,
})
```

Use `false` for instant startup. If you enable loading, keep the transition short and provide an obvious way to continue or disable it for users who do not want audio.

## Cleanup

Destroy the interface when your script is finished or being reloaded.

```lua
UI:Destroy()
```

Cleanup removes the interface and library-managed input connections. If you create additional ScreenGuis or connections in your own showcase, clean those up separately.

## Building a showcase

A strong buyer demo should be easy to understand within a minute:

1. Start with a welcome tab showing the design and a notification button.
2. Use a Controls tab to demonstrate every input type.
3. Add a Settings tab for configuration save/load/list behavior.
4. Keep example names generic: `Example button`, `Example slider`, and `Example dropdown`.
5. Use a stable hosted source or a cache-free loader for testing.
6. Include screenshots and a short feature list in your product post.

The repository includes ready-to-run references:

- `ProductShowcase.client.lua` — complete buyer-facing control and configuration demo.
- `CacheFreeProductShowcase.client.lua` — cache-free launcher for the product showcase.
- `CompleteShowcase.client.lua` — broad API tour with appearance examples.
- `ButtonsSettingsShowcase.client.lua` — focused buttons/settings demo.
- `StatsHudShowcase.client.lua` — optional draggable stats HUD example.
- `AutoCollect.client.lua` — game-specific UI wiring example; keep gameplay logic separate from the library.

## Production checklist

- Replace placeholder raw URLs and asset IDs.
- Pin public loaders to a commit for reproducible releases.
- Use unique flags for every persisted control.
- Test at the minimum window size.
- Test mouse, keyboard, touch, and search behavior where relevant.
- Test with and without file APIs.
- Keep descriptions short enough to avoid truncation.
- Decide whether loading audio belongs in your product.
- Clean up custom connections and UI objects on shutdown.
- Keep game behavior in your own script callbacks.

## License and buyer terms

The commercial offer for the current package is **$15 one time** and may include the source code, documentation, showcase examples, updates, and support according to the seller’s stated terms.

Before selling, clearly define whether buyers receive:

- Commercial use in their own projects.
- Permission to modify the source.
- Permission to ship the library inside their products.
- Updates and support.
- Redistribution restrictions.
- Resale or sublicensing restrictions.

Do not describe a license as a transfer of copyright unless that is actually what you intend to provide.
