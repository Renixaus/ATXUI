# Elements

All elements are called on a `Tab`, `Section`, `Group`, `HStack`, or `VStack` object.

**Common fields shared by every interactive element:**

| Field | Type | Description |
|---|---|---|
| `Title` | `string` | Element label |
| `Desc` | `string` | Sub-label / description |
| `Icon` | `string` | Icon name (lucide / sf / craft prefix) |
| `Locked` | `boolean` | Starts locked (grayed out, non-interactive) |
| `LockedTitle` | `string` | Text shown on the lock overlay |
| `Flag` | `string` | Key used by ConfigManager to save/load this element |

**Common methods on every returned element:**

```lua
element:Lock()
element:Unlock()
element:SetTitle("New Title")
element:SetDesc("New desc")
element:Destroy()
```

---

## Toggle

```lua
local t = Tab:Toggle({
    Title    = "Fly",
    Desc     = "Toggle fly mode",
    Icon     = "lucide:plane",
    Value    = false,
    Type     = "Toggle",   -- "Toggle" (default) or "Checkbox"
    IconSize = 23,
    Flag     = "fly",
    Callback = function(v: boolean) end,
})

t:Set(true)          -- set value (fires callback)
t:Set(true, false)   -- set value, skip callback
print(t.Value)       -- current value
```

Clicking anywhere on the element row toggles the value — not just the widget.

---

## Slider

```lua
local s = Tab:Slider({
    Title     = "Walk Speed",
    Desc      = "Default is 16",
    Value     = { Min = 1, Max = 100, Default = 16 },
    Step      = 1,
    IsTooltip = true,   -- show floating value tooltip while dragging
    IsTextbox = true,   -- show editable number input
    Icons     = { From = "lucide:volume", To = "lucide:volume-2" },
    Flag      = "walkspeed",
    Callback  = function(v: number) end,
})

s:Set(50)
s:SetMin(0)
s:SetMax(200)
print(s.Value.Default)  -- current value
```

---

## Dropdown

```lua
local d = Tab:Dropdown({
    Title            = "Mode",
    Desc             = "Select a mode",
    Values           = { "Box", "Skeleton", "Head Dot" },
    Value            = "Box",          -- default selected (string or table for Multi)
    Multi            = false,
    AllowNone        = false,
    SearchBarEnabled = false,
    MenuWidth        = 180,
    Flag             = "espmode",
    Callback         = function(v) end, -- v is string (single) or table (multi)
})

d:Select("Skeleton")
d:Refresh()         -- re-render values
d:Display()         -- update label text
d:Open()
d:Close()
print(d.Value)
```

**Multi-select** — `Value` defaults to a table, callback receives a table of selected strings.

---

## Input

```lua
local i = Tab:Input({
    Title            = "Server ID",
    Desc             = "Enter a place ID",
    Placeholder      = "Place ID...",
    Value            = "",
    Type             = "Input",      -- "Input" (default) or "Textarea"
    ClearTextOnFocus = false,
    Width            = 150,
    Flag             = "serverid",
    Callback         = function(v: string) end,  -- fires on FocusLost
})

i:Set("12345678")
i:SetPlaceholder("Type here...")
print(i.Value)
```

---

## Keybind

```lua
local k = Tab:Keybind({
    Title     = "Toggle ESP",
    Desc      = "Press to rebind",
    Value     = Enum.KeyCode.X,
    CanChange = true,   -- allow user to rebind by clicking
    Flag      = "espkey",
    Callback  = function(key: Enum.KeyCode) end,
})

k:Set(Enum.KeyCode.F)
print(k.Value)
```

---

## Colorpicker

```lua
local c = Tab:Colorpicker({
    Title        = "Chams Color",
    Desc         = "ESP highlight color",
    Default      = Color3.fromRGB(120, 100, 255),
    Transparency = 0,       -- initial alpha (0 = fully opaque)
    Flag         = "chamscolor",
    Callback     = function(color: Color3, transparency: number) end,
})

c:Set(Color3.fromRGB(255, 80, 80), 0.3)
```

When `Transparency` is provided the color picker shows an opacity slider.

---

## Button

```lua
Tab:Button({
    Title    = "Rejoin",
    Desc     = "Reconnect to the server",
    Icon     = "lucide:refresh-cw",
    Variant  = "Secondary",   -- "Primary" or "Secondary"
    Flag     = "rejoin",
    Callback = function() end,
})
```

---

## Paragraph

```lua
Tab:Paragraph({
    Title   = "About",
    Desc    = "ATX_UI — smooth UI library for Roblox scripts.",
    Buttons = {
        { Title = "GitHub",  Icon = "lucide:github",    Callback = function() end },
        { Title = "Discord", Icon = "lucide:message-circle", Callback = function() end },
    },
})
```

---

## Code

```lua
local c = Tab:Code({
    Title  = "Quick Start",
    Code   = [[local UI = loadstring(...)()
local Win = UI:CreateWindow({ Title = "My Script" })
]],
    OnCopy = function() end,   -- called when user clicks copy
})

c:Set("-- new code here")
```

---

## Image

```lua
Tab:Image({
    Image       = "rbxassetid://6031280882",
    AspectRatio = "16:9",   -- "1:1", "4:3", "16:9", or number ratio
    Radius      = 8,
})
```

---

## Divider

```lua
Tab:Divider()
```

Horizontal separator line.

---

## Space

```lua
Tab:Space()
Tab:Space({ Columns = 2 })   -- double-height space
```

---

## Section

```lua
local sec = Tab:Section({
    Title        = "Movement",
    Desc         = "Player movement options",
    Icon         = "lucide:footprints",
    IconThemed   = true,
    Opened       = true,    -- expanded by default
    Box          = true,    -- background card around content
    BoxBorder    = false,   -- border around the box
    TextSize     = 19,
    DescTextSize = 16,
})

-- Add elements to the section
sec:Toggle({ Title = "Fly", ... })
sec:Slider({ Title = "Speed", ... })

sec:Open()
sec:Close()
sec:SetTitle("New Title")
sec:SetIcon("lucide:zap")
```

---

## Group

Lays out child elements **horizontally**, splitting available width equally.

```lua
local g = Tab:Group()
g:Button({ Title = "A", Callback = function() end })
g:Button({ Title = "B", Callback = function() end })
g:Button({ Title = "C", Callback = function() end })
```

---

## HStack

Same as Group — explicit horizontal layout container.

```lua
local h = Tab:HStack()
h:Toggle({ Title = "Anti-AFK",  Value = true,  Callback = function(v) end })
h:Toggle({ Title = "Auto-Farm", Value = false, Callback = function(v) end })
```

---

## VStack

Vertical layout container (stacks elements top-to-bottom, useful inside Group/HStack).

```lua
local v = Tab:VStack()
v:Button({ Title = "Action 1", Callback = function() end })
v:Button({ Title = "Action 2", Callback = function() end })
```
