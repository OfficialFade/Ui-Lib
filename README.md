# Clapped Hub UI Lib

Clapped Hub is a premium Roblox interface library. It provides a dark futuristic window, responsive tabs, polished sections, controls, notifications, theming, subtle motion, and an optional built-in loading music transition.

The library contains no gameplay, exploit, cheat, automation, bypass, or game-manipulation functionality. Its built-in music transition is a client-side presentation effect.

## Quick start

```lua
local Library = loadstring(game:HttpGet("YOUR_RAW_URL/ClappedHub.lua"))()

local UI = Library.new({
    Name = "CLAPPED HUB",
    Subtitle = "PRIVATE INTERFACE SYSTEM",
})

local overview = UI:Tab({
    Name = "Overview",
    Icon = "⌂",
    Description = "A focused command surface for your interface.",
})

local appearance = UI:Section({
    Tab = overview,
    Name = "Appearance",
    Description = "Tune the visual layer.",
})

appearance:Toggle({
    Name = "Ambient glow",
    Description = "Controls a presentation-only visual preference.",
    Flag = "AmbientGlow",
    Default = true,
    Callback = function(enabled)
        print("Ambient glow:", enabled)
    end,
})

appearance:Slider({
    Name = "Intensity",
    Min = 0,
    Max = 100,
    Default = 70,
    Callback = function(value)
        print("Intensity:", value)
    end,
})

appearance:Keybind({
    Name = "Toggle overlay",
    Key = Enum.KeyCode.V,
    Mode = "Toggle", -- Use "Hold" for press-and-hold behavior.
    Callback = function(enabled)
        print("Overlay enabled:", enabled)
    end,
})

appearance:KeybindListToggle({
    Name = "Show keybinds",
    Default = false,
})

UI:Notify({
    Title = "Interface ready",
    Content = "Your presentation layer is online.",
    Icon = "✦",
})
```

Callbacks can run any client-side code available to the host script:

```lua
local runButton = appearance:Button({
    Name = "Run action",
    Text = "RUN",
    Callback = function()
        print("Your script ran")
    end,
})

runButton.SetEnabled(false)
runButton.SetText("DISABLED")
```

`Toggle` and `Slider` return `Set` and `Get` methods, and every callback receives the current value.

The built-in search bar filters controls by name and description and switches to the first matching tab. Click a keybind value to choose a new key; press Escape to cancel. Keybinds are shown in a compact draggable panel and enabled entries are highlighted.

## Included primitives

- Draggable glass-and-metal window with minimize and close controls
- Responsive, scrollable sidebar navigation
- Animated tab transitions and active states
- Sections, labels, buttons, toggles, sliders, keybind pickers, and notification stacks
- Global settings search and a draggable keybind list panel
- Centralized accent theme with optional custom accent color
- UI state flags and callbacks only
- Built-in slim loading screen with timed client-side music transition
