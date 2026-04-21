# Advanced

## Themes

### Built-in themes

`Dark` · `Light` · `Rose` · `Plant` · `Red` · `Indigo` · `Sky` · `Violet` · `Amber` · `Emerald` · `Midnight` · `Crimson` · `Monokai Pro` · `Cotton Candy` · `Mellowsi` · `Rainbow`

```lua
ATXUI:SetTheme("Dark")
ATXUI:GetCurrentTheme()   -- → "Dark"
ATXUI:GetThemes()         -- → table of all themes
```

### Custom theme

Pass a table with a `Name` field to `AddTheme`, then activate it with `SetTheme`.

```lua
ATXUI:AddTheme({
    Name               = "Ocean",
    Background         = Color3.fromHex("#0a0e1a"),
    MainBackground     = Color3.fromHex("#0d1220"),
    ElementBackground  = Color3.fromHex("#131928"),
    Accent             = Color3.fromHex("#3b82f6"),
    Toggle             = Color3.fromHex("#3b82f6"),
    Checkbox           = Color3.fromHex("#3b82f6"),
    Button             = Color3.fromHex("#3b82f6"),
    Text               = Color3.fromHex("#e2e8f0"),
    SubText            = Color3.fromHex("#64748b"),
    PlaceholderText    = Color3.fromHex("#334155"),
    TabBackground      = Color3.fromHex("#131928"),
    TabTitle           = Color3.fromHex("#e2e8f0"),
})

ATXUI:SetTheme("Ocean")
```

### Theme change callback

```lua
ATXUI:OnThemeChange(function(themeName)
    print("Theme changed to:", themeName)
end)
```

---

## Notifications

```lua
ATXUI:Notify({
    Title    = "Hello",
    Content  = "Operation complete.",
    Icon     = "lucide:check-circle",
    Duration = 4,       -- seconds (nil = stays until dismissed)
})
```

### Lower position (mobile / UI overlap)

```lua
ATXUI:SetNotificationLower(true)
```

---

## Popup

Floating modal that appears over the UI.

```lua
ATXUI:Popup({
    Title   = "Welcome",
    Icon    = "lucide:sparkles",
    Content = "This is a popup.",
    Buttons = {
        {
            Title    = "Get Started",
            Icon     = "lucide:arrow-right",
            Variant  = "Primary",
            Callback = function() end,
        },
    },
})
```

---

## Gradient background

```lua
local Window = ATXUI:CreateWindow({
    Background = ATXUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#0f0f1a"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#1a0f2e"), Transparency = 0 },
    }, { Rotation = 135 }),
})
```

---

## Localization

```lua
local Loc = ATXUI:Localization({
    Enabled         = true,
    Prefix          = "loc:",
    DefaultLanguage = "en",
    Translations    = {
        en = {
            FLY_TITLE = "Fly",
            SPEED_DESC = "Player walk speed",
        },
        tr = {
            FLY_TITLE = "Uçuş",
            SPEED_DESC = "Oyuncu yürüme hızı",
        },
    },
})

ATXUI:SetLanguage("tr")

Tab:Toggle({ Title = "loc:FLY_TITLE", Desc = "loc:SPEED_DESC", ... })
```

---

## ConfigManager

Saves and loads element values to JSON files on the executor filesystem.

### Setup

```lua
local Window = ATXUI:CreateWindow({
    Folder = "MyScript",   -- required for ConfigManager
    ...
})
```

### Create / load a config

```lua
local Config = Window.ConfigManager:CreateConfig("default", true)
-- 2nd arg = autoload on startup
```

### Register elements

```lua
local speedSlider = Tab:Slider({
    Title = "Speed",
    Flag  = "speed",      -- Flag automatically registers with current config
    ...
})

-- or manually:
Config:Register("speed", speedSlider)
```

When `Flag` is set and a current config exists, the element is registered automatically and its value restored from the save file.

### Save / Load / Delete

```lua
Config:Save()
Config:Load()
Config:Delete()
```

### Custom data

```lua
Config:Set("lastGame", game.PlaceId)
local id = Config:Get("lastGame")
```

### Multiple configs

```lua
local cfg1 = Window.ConfigManager:CreateConfig("preset1")
local cfg2 = Window.ConfigManager:CreateConfig("preset2")

cfg1:SetAsCurrent()   -- make cfg1 active (elements register here)
cfg1:Save()

Window.ConfigManager:AllConfigs()       -- → list of filenames
Window.ConfigManager:DeleteConfig("preset2")
```

---

## KeySystem

Gate the window behind a key. Supported services: **Platoboost**, **PandaDevelopment**, **JunkieDevelopment**, **Luarmor**.

### Simple key list

```lua
local Window = ATXUI:CreateWindow({
    Folder    = "MyScript",
    KeySystem = {
        Title   = "Key Required",
        Note    = "Get your key at the link below",
        URL     = "https://example.com/getkey",
        Key     = { "KEY-ALPHA-001", "KEY-BETA-002" },
        SaveKey = true,
    },
    ...
})
```

### Custom validator

```lua
KeySystem = {
    Title        = "Key Required",
    KeyValidator = function(key)
        -- return true if key is valid, false otherwise
        return key:sub(1, 4) == "ATX-"
    end,
    SaveKey = true,
}
```

### API service (Platoboost example)

```lua
KeySystem = {
    Title = "Key Required",
    API   = {
        {
            Type     = "Platoboost",
            Id       = "your-app-id",
            Title    = "Platoboost",
            Icon     = "lucide:key",
        },
    },
    SaveKey = true,
}
```

---

## Font

```lua
ATXUI:SetFont("rbxasset://fonts/families/GothamSSm.json")
```

---

## UI Scale

```lua
Window:SetUIScale(0.85)   -- shrink UI to 85%
Window:GetUIScale()       -- → 0.85
```

`AutoScale = true` (default) automatically scales down on small screens.

---

## Open button (mobile)

The floating button that reopens the window when minimized.

```lua
local Window = ATXUI:CreateWindow({
    OpenButton = {
        Icon     = "lucide:layout-dashboard",
        Position = UDim2.new(0, 20, 0.5, 0),
    },
})

-- or edit after creation:
Window:EditOpenButton({
    Icon = "lucide:menu",
})
```
