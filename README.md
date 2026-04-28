# ATX_UI

A modern, feature-rich, and highly customizable UI Library for Roblox scripts. Designed with a focus on fluid micro-animations, premium glassmorphism, and excellent user experience.

> [!WARNING]  
> ATX_UI is currently in Beta. You may encounter bugs or unstable features.

## Installation

```lua
local ATXUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/atx/main/dist/main.lua"))()
```

## Quick Start

```lua
local ATXUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/atx/main/dist/main.lua"))()

-- 1. Create a Window
local Window = ATXUI:CreateWindow({
    Title = "My Premium Hub",
    Size = UDim2.fromOffset(580, 460),
})

-- 2. Create a Tab Folder (Collapsible Sub-Tabs)
local MainFolder = Window:TabFolder({ Title = "Main Features", Icon = "folder" })

-- 3. Add a Tab inside the Folder
local Dashboard = MainFolder:Tab({ Title = "Dashboard", Icon = "home" })

-- 4. Create Stat Cards for a modern dashboard look
local StatsGroup = Dashboard:HStack()
StatsGroup:StatCard({ Title = "Network Ping", Value = "42 ms", Icon = "wifi" })
StatsGroup:StatCard({ Title = "Client FPS", Value = "60", Icon = "monitor" })

-- 5. Standard elements with micro-animations
Dashboard:Toggle({
    Title = "Auto Farm",
    Desc = "Automatically starts the farming process",
    Value = false,
    Callback = function(state)
        -- 6. Trigger a swipe-to-dismiss notification
        ATXUI:Notify({
            Title = "Auto Farm",
            Content = state and "Successfully started." or "Stopped.",
            Icon = "info",
            Duration = 3
        })
    end
})
```

## Key Features

🚀 **Modern UI Elements**
- **Stat Cards:** Custom dashboard elements to display real-time data.
- **17+ Elements** (Buttons, Toggles, Sliders, Dropdowns, Colorpickers, Keybinds, etc.)
- **Grid & Layouts:** `HStack`, `VStack`, `Group`, `Divider`, `Space`.
- Smooth micro-animations (press, hover, spring transitions).

📂 **Advanced Navigation**
- Sidebar with **Tab Folders** (Collapsible Sub-Tabs).
- Mac-style or Default topbar variations.
- Resizable, draggable, and fullscreen-capable windows.

🎨 **Visuals & Customization**
- **Acrylic Glassmorphism:** Live blur effects on supported executors.
- 16 Built-in themes + custom theme API.
- Gradient background support.

🔔 **Interactive Modals**
- **Swipe-to-Dismiss Notifications:** Modern notification queue with max-limits and sliding animations.
- Dialogs, Popups, and Tooltips with rich-text support.

⚙️ **Powerful Utilities**
- **ConfigManager:** Auto-save and load element values as JSON.
- **KeySystem:** Built-in integration for Platoboost, PandaDevelopment, Luarmor, or custom validators.
- Multi-language string keys (Localization).

## Documentation

- [Window & Tabs](docs/window.md)
- [UI Elements](docs/elements.md)
- [Advanced Features](docs/advanced.md)

## License
MIT License
