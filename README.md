# ATX_UI

A feature-rich Roblox UI library for scripts — smooth micro-animations, glass effects, theming, and a full element suite.

> [!WARNING]
> ATX_UI is currently in Beta. Bugs and unstable features may occur.

## Installation

```lua
local ATXUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/main/dist/main.lua"
))()
```

## Quick start

```lua
local ATXUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/main/dist/main.lua"
))()

ATXUI:SetTheme("Dark")

local Window = ATXUI:CreateWindow({
    Title     = "My Script",
    Size      = UDim2.fromOffset(580, 460),
    Folder    = "MyScript",
    ToggleKey = Enum.KeyCode.RightControl,
})

local Tab = Window:Tab({ Title = "Main", Icon = "lucide:home" })

Tab:Toggle({
    Title    = "Feature",
    Value    = false,
    Callback = function(v) end,
})

Tab:Slider({
    Title    = "Speed",
    Value    = { Min = 1, Max = 100, Default = 16 },
    Step     = 1,
    Callback = function(v) end,
})
```

A full working example: [main_example.lua](main_example.lua)

## Features

- Window with sidebar navigation, drag, resize, fullscreen
- **17 elements** — Button, Toggle, Slider, Dropdown, Input, Keybind, Colorpicker, Paragraph, Code, Image, Divider, Space, Group, HStack, VStack, Section, Label
- Smooth micro-animations — press, hover, spring transitions
- Full-row click on toggles (click title/desc area, not just the widget)
- Mac-style and Default topbar variants
- **16 built-in themes** + custom theme API + gradient backgrounds
- ConfigManager — save/load element values as JSON
- KeySystem — Platoboost / PandaDevelopment / Luarmor / custom validator
- Notification, Dialog, Popup, Tooltip
- Localization (multi-language string keys)
- Acrylic/blur background, AutoScale, mobile open button

## Documentation

| Page | Contents |
|---|---|
| [Window & Tab](docs/window.md) | `CreateWindow` config, all window methods, Tab, Dialog, Topbar |
| [Elements](docs/elements.md) | All 17 elements with config tables and examples |
| [Advanced](docs/advanced.md) | Themes, Notifications, Popup, ConfigManager, KeySystem, Localization |

## Credits

#### Icons
- [Lucide Icons](https://github.com/lucide-icons/lucide)
- [Craft Icons](https://www.figma.com/community/file/1415718327120418204)
- [Geist Icons](https://vercel.com/geist/icons)
- [Solar Icons](https://icones.js.org/collection/solar)
- [SF Symbols](https://sf-symbols-one.vercel.app/)

## License

MIT
