# Clapped Hub UI Lib

Clapped Hub UI Lib is a presentation-focused Roblox interface library for polished script panels, settings menus, dashboards, and showcases. It includes a glass-style window, responsive navigation, searchable controls, keybind management, notifications, configuration storage, theming, and an optional loading transition.

The library owns UI state and callbacks. Your game or script owns the actual behavior inside those callbacks.

## Installation

Load the library from your hosted raw URL, then create one library instance. Replace the example URL with your own stable, versioned release URL before shipping.

```lua
local source = game:HttpGet("YOUR_RAW_URL/ClappedHub.lua")
local Library = assert(loadstring(source), "Could not load the UI library")()

local UI = Library.new({
    Name = "MY HUB",
    Subtitle = "CONTROL PANEL",
    EnableLoadingMusic = false,
})
```

Ready-to-run references included in this package:

- `ExampleShowcase.client.lua` — presentation script with Example 1–4 tabs.
- `Example.client.lua` — broad feature reference.
- `FullExample.client.lua` — customization-focused reference.
- `AutoCollect.client.lua` — game-specific example; keep gameplay logic separate from the UI library.

## First panel

The normal construction flow is tab, section, then controls:

```lua
local tab = UI:Tab({
    Name = "Settings",
    Icon = "⚙",
    Description = "Configure your preferences.",
})

local section = UI:Section({
    Tab = tab,
    Name = "General",
    Description = "Common interface settings.",
})

section:Toggle({
    Name = "Notifications",
    Description = "Show feedback messages.",
    Flag = "Notifications",
    Default = true,
    Callback = function(enabled)
        print("Notifications:", enabled)
    end,
})

UI:Notify({
    Title = "Ready",
    Content = "The interface loaded successfully.",
    Icon = "✓",
    Duration = 4,
})
```

Create tabs before sections. Names and descriptions are indexed by the built-in search bar, so use concise, searchable wording.

## Constructor options

All options are optional and have sensible defaults.

| Option | Type | Purpose |
| --- | --- | --- |
| `Name` | string | Main window title. |
| `Subtitle` | string | Small title below the main title. |
| `ProfileUserName` | string | Profile-card text; defaults to the local player name. |
| `ScriptType` | `"FREE"` or `"PAID"` | Controls the profile badge. |
| `Accent` | Color3 | Primary highlight color. |
| `Theme` | table | Overrides named theme colors; unknown keys are ignored. |
| `IconImage` | string | Main logo asset ID. `Icon` and `LogoImage` are aliases. |
| `BackgroundImage` | string | Glass background asset ID. |
| `BackgroundImageTransparency` | number | Background transparency from `0` to `1`. |
| `ShowBackground` | boolean | Shows or hides the glass background. |
| `WindowSize` | Vector2 or UDim2 | Initial window size. |
| `WindowPosition` | UDim2 | Initial window position. |
| `WindowMinSize` | Vector2 | Minimum window size. |
| `WindowMaxSize` | Vector2 | Maximum window size. |
| `AspectRatio` | number | Responsive window aspect ratio. |
| `EnableDragging` | boolean | Allows dragging from the header. |
| `EnableMinimize` | boolean | Shows the minimize control. |
| `CollapsibleSidebar` | boolean | Enables sidebar collapsing. |
| `AutoCollapseSidebar` | boolean | Collapses the sidebar when the pointer leaves it. |
| `SidebarExpandedWidth` | number | Expanded sidebar width in pixels. |
| `SidebarCollapsedWidth` | number | Collapsed sidebar width in pixels. |
| `SidebarCollapseDelay` | number | Auto-collapse delay in seconds. |
| `ShowSearch` | boolean | Shows the sidebar search control. |
| `ShowProfile` | boolean | Shows the profile card. |
| `EnableLoadingMusic` | boolean | Enables the optional loading transition and music. |

Example production-style setup:

```lua
local UI = Library.new({
    Name = "EXAMPLE HUB",
    Subtitle = "PRODUCTION PANEL",
    IconImage = "rbxassetid://1234567890",
    Accent = Color3.fromRGB(110, 190, 255),
    Theme = {
        Background = Color3.fromRGB(7, 10, 18),
        Window = Color3.fromRGB(14, 17, 28),
        Surface = Color3.fromRGB(24, 30, 45),
        SurfaceRaised = Color3.fromRGB(35, 44, 65),
        SurfaceHover = Color3.fromRGB(48, 64, 92),
        Text = Color3.fromRGB(242, 247, 255),
        TextMuted = Color3.fromRGB(163, 180, 208),
    },
    WindowSize = Vector2.new(720, 620),
    WindowPosition = UDim2.fromScale(0.5, 0.5),
    CollapsibleSidebar = false,
    AutoCollapseSidebar = false,
    EnableLoadingMusic = false,
})
```

Supported theme keys are `Background`, `Window`, `Sidebar`, `Surface`, `SurfaceRaised`, `SurfaceHover`, `Stroke`, `StrokeSoft`, `Text`, `TextMuted`, `TextFaint`, `Accent`, `AccentBright`, `AccentDeep`, `Success`, `Warning`, and `Danger`.

## Tabs and sections

```lua
local tab = UI:Tab({
    Name = "Appearance",
    Icon = "◉",
    Description = "Visual preferences and display options.",
})

local section = UI:Section({
    Tab = tab,
    Name = "Theme",
    Description = "Adjust the look of the panel.",
})
```

Tab labels are bold for readability. For a permanently expanded sidebar, leave both sidebar-collapse options disabled.

## Controls

### Label

```lua
section:Label({
    Title = "Status",
    Text = "Online",
})
```

### Button

```lua
local button = section:Button({
    Name = "Run action",
    Text = "RUN",
    Description = "Executes a one-time callback.",
    Callback = function()
        print("Action ran")
    end,
})

button.SetEnabled(false)
button.SetText("DISABLED")
```

### Toggle

```lua
local toggle = section:Toggle({
    Name = "Enabled",
    Flag = "Enabled",
    Default = false,
    Callback = function(value)
        print("Enabled:", value)
    end,
})

toggle.Set(true)       -- second argument true suppresses the callback
print(toggle.Get())
```

### Slider

```lua
section:Slider({
    Name = "Opacity",
    Flag = "Opacity",
    Min = 0,
    Max = 100,
    Default = 75,
    Format = "%d%%",
    Callback = function(value)
        print("Opacity:", value)
    end,
})
```

Slider values are clamped between `Min` and `Max`. The returned control supports `Set` and `Get`.

### Dropdown

```lua
section:Dropdown({
    Name = "Mode",
    Flag = "Mode",
    Width = 150,
    Options = {"Balanced", "Fast", "Quiet"},
    Default = "Balanced",
    Callback = function(value)
        print("Mode:", value)
    end,
})
```

Use `Width` for longer option names. Dropdown values are displayed with a font-safe arrow and clean truncation. Buttons also accept an optional `Width` value when the action text needs more room.

### TextBox

```lua
local nameBox = section:TextBox({
    Name = "Display name",
    Description = "Text is padded and truncated cleanly.",
    Width = 160,
    Flag = "DisplayName",
    Placeholder = "Enter a name...",
    Default = "Player",
    Live = false,
    Callback = function(value)
        print("Name:", value)
    end,
})
```

With `Live = true`, the callback runs as text changes. Otherwise it runs when focus is lost. The returned control supports `Set`, `Get`, and `Input`.

### ColorPicker

```lua
section:ColorPicker({
    Name = "Accent color",
    Flag = "AccentColor",
    Default = Color3.fromRGB(110, 190, 255),
    Callback = function(color)
        print("Color:", color)
    end,
})
```

The picker supports hue, saturation/value, hex input, RGB channels, preview, and programmatic `Set`/`Get` methods.

### Keybind

```lua
section:Keybind({
    Name = "Toggle panel",
    Flag = "TogglePanel",
    Key = Enum.KeyCode.B,
    Mode = "Toggle", -- or "Hold"
    Callback = function(enabled)
        print("Keybind state:", enabled)
    end,
})
```

Click a key value to choose a new key. Press Escape to cancel. `Hold` keybinds remain active only while the key is held.

## Runtime customization

```lua
UI:SetWindowSize(Vector2.new(800, 680))
UI:SetWindowPosition(UDim2.fromScale(0.5, 0.46))
UI:SetTheme({Accent = Color3.fromRGB(255, 110, 175)})
UI:SetAccent(Color3.fromRGB(110, 220, 170))
UI:SetIcon("rbxassetid://1234567890")
UI:SetLogo("rbxassetid://1234567890")
UI:SetBackgroundImage("rbxassetid://78664802433772", 0.25)
UI:SetBackgroundVisible(true)
UI:SetSearchVisible(false)
UI:SetProfileVisible(true)
UI:SetSidebarAutoCollapse(false)
```

`SetTheme` updates the main surfaces and navigation accent at runtime. For a complete visual preset, pass the full `Theme` table during construction, then use `SetAccent` and `SetBackgroundImage` for live user choices.

## Notifications

```lua
UI:Notify({
    Title = "Saved",
    Content = "Your settings were saved.",
    Icon = "✓",
    Color = Color3.fromRGB(74, 205, 143),
    Duration = 3,
})
```

`Content` and `Text` are both accepted. Notifications stack in the lower-right corner and animate automatically.

## Hub and keybind panel

```lua
UI:SetKeybindPanelVisible(true)
UI:SetHubVisible(false)
UI:SetHubVisible(true)
UI:ToggleHub()
```

```lua
section:KeybindListToggle({Name = "Show keybinds", Default = false})
section:HubToggleKeybind({Name = "Toggle hub", Key = Enum.KeyCode.RightShift})
```

`ToggleHubKeybind` is an alias for `HubToggleKeybind`.

## Configuration manager

The configuration manager stores flags, colors, text values, dropdown values, slider values, keybinds, hub visibility, and keybind-panel state.

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

The manager also provides `SaveConfig`, `LoadConfig`, and `DeleteConfig` aliases. If file APIs are unavailable, operations return `false` with an explanatory message. Show that message to users instead of silently failing.

## Loading transition

The loading transition is optional:

```lua
local UI = Library.new({
    EnableLoadingMusic = true,
})
```

Set `EnableLoadingMusic = false` for instant startup. You can call `UI:PlayMusic({...})` for a custom loading/audio presentation. Keep loading short and always offer an instant-start option.

## Production checklist

1. Replace the development raw URL and placeholder asset IDs with stable production versions.
2. Give every persistent control a unique `Flag`.
3. Keep names and descriptions short enough for the minimum window size.
4. Test search, keyboard input, mouse input, touch input, and narrow viewports as applicable.
5. Test config operations when file APIs are unavailable.
6. Decide whether loading music belongs in your product; disable it with `EnableLoadingMusic = false` if not.
7. Call `UI:Destroy()` during cleanup so the ScreenGui and input handlers are removed.
8. Keep gameplay or remote-event logic in the owning script, not inside this reusable UI module.

## Included features

- Custom title, subtitle, logo, theme, accent, background, size, position, and layout.
- Optional loading transition and music.
- Bold searchable sidebar navigation with optional auto-collapse.
- Tabs, sections, labels, buttons, toggles, sliders, dropdowns, text boxes, color pickers, and keybinds.
- Toggle and hold keybind modes with a draggable keybind panel.
- Animated notifications and hub visibility controls.
- JSON configuration manager with save, load, delete, and list operations.
- UI-only callbacks with no built-in gameplay or remote-event behavior.
