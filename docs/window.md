# Window

## CreateWindow

```lua
local Window = ATXUI:CreateWindow(Config)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"UI Library"` | Window title |
| `Author` | `string` | — | Subtitle shown below the title |
| `Icon` | `string` | — | Icon ID or lucide/sf name |
| `IconSize` | `number` | `22` | Icon pixel size |
| `IconThemed` | `boolean` | — | Tint icon with theme color |
| `IconRadius` | `number` | `0` | Icon corner radius |
| `Size` | `UDim2` | `UDim2.fromOffset(580, 460)` | Initial window size |
| `MinSize` | `Vector2` | `Vector2.new(560, 350)` | Minimum resize size |
| `MaxSize` | `Vector2` | `Vector2.new(850, 560)` | Maximum resize size |
| `SideBarWidth` | `number` | `200` | Sidebar (tab list) width |
| `Folder` | `string` | — | Folder name for config saves |
| `Transparent` | `boolean` | `false` | Glass/transparent background |
| `Acrylic` | `boolean` | `false` | Acrylic blur background |
| `Resizable` | `boolean` | `true` | Allow drag-resize |
| `AutoScale` | `boolean` | `true` | Scale to fit smaller screens |
| `ToggleKey` | `Enum.KeyCode` | — | Key to show/hide window |
| `Theme` | `string` | `"Dark"` | Active theme name |
| `Topbar` | `table` | `{Height=52, ButtonsType="Default"}` | `ButtonsType`: `"Default"` or `"Mac"` |
| `HideSearchBar` | `boolean` | `false` | Hide the sidebar search input |
| `ScrollBarEnabled` | `boolean` | `false` | Show scrollbar on sidebar |
| `NewElements` | `boolean` | `false` | Alternate element style |
| `HidePanelBackground` | `boolean` | `false` | Hide the content panel background |
| `IgnoreAlerts` | `boolean` | `false` | Skip close-confirm dialog |
| `Background` | `string \| Color3 \| table` | — | Window background (image URL, `Color3`, or gradient table) |
| `ShadowTransparency` | `number` | `0.6` | Drop-shadow opacity |
| `User` | `table` | — | User profile widget (see below) |
| `OpenButton` | `table` | — | Floating open button config |
| `KeySystem` | `table` | — | Key-gate config (see [Advanced](advanced.md)) |

### User widget

```lua
User = {
    Enabled   = true,
    Anonymous = false,     -- hide real username
    Callback  = function() end,
}
```

### Background gradient

```lua
Background = ATXUI:Gradient({
    ["0"]   = { Color = "#111", Transparency = 0 },
    ["100"] = { Color = "#222", Transparency = 0 },
}, { Rotation = 90 })
```

---

## Window methods

```lua
Window:Open()
Window:Close()
Window:Toggle()
Window:Destroy()

Window:SetTitle("New Title")
Window:SetAuthor("v2.0")
Window:SetSize(UDim2.fromOffset(640, 480))
Window:SetUIScale(0.9)
Window:GetUIScale()          -- → number
Window:SetToggleKey(Enum.KeyCode.RightAlt)
Window:ToggleFullscreen()
Window:SetToTheCenter()

Window:SetBackgroundImage("rbxassetid://…")
Window:SetBackgroundImageTransparency(0.5)
Window:SetBackgroundTransparency(0.15)
Window:SetPanelBackground(false)   -- hide/show content panel bg
Window:ToggleTransparency(true)
Window:IsResizable(false)

Window:LockAll()
Window:UnlockAll()
Window:GetLocked()     -- → table of locked elements
Window:GetUnlocked()   -- → table of unlocked elements

Window:OnOpen(function() end)
Window:OnClose(function() end)
Window:OnDestroy(function() end)

Window:DisableTopbarButtons({"Fullscreen", "Minimize"})
```

---

## Tab

```lua
local Tab = Window:Tab(Config)
```

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Tab"` | Tab label |
| `Icon` | `string` | — | Icon name |
| `IconColor` | `Color3` | — | Fixed icon color (disables theming) |
| `IconShape` | `string` | — | `"Circle"` or any value for rounded bg |
| `IconThemed` | `boolean` | — | Tint icon with theme |
| `Desc` | `string` | — | Tooltip text on hover |
| `Locked` | `boolean` | `false` | Disable tab selection |
| `ShowTabTitle` | `boolean` | `false` | Show large title inside the content panel |
| `TabTitleAlign` | `string` | `"Left"` | `"Left"`, `"Center"`, `"Right"` |
| `Border` | `boolean` | — | Show tab border outline |
| `CustomEmptyPage` | `table` | — | `{Icon, IconSize, Title, Desc}` shown when tab has no elements |

```lua
Tab:Select()            -- programmatically switch to this tab
Tab:LockAll()
Tab:UnlockAll()
Tab:GetLocked()
Tab:GetUnlocked()
Tab:ScrollToTheElement(index)
```

All element methods (Toggle, Slider, etc.) are available directly on `Tab`.

---

## Section (sidebar)

```lua
Window:Section({ Title = "Group", Icon = "lucide:layers" })
```

Renders a collapsible section label in the **sidebar** (between tabs), not inside tab content. For a content section use `Tab:Section(...)`.

---

## Topbar buttons

```lua
Window:CreateTopbarButton(
    "Name",
    "lucide:bell",
    function() end,
    990,          -- LayoutOrder (higher = further left)
    false,        -- IconThemed
    Color3.fromHex("#5a5aff"),
    16            -- IconSize
)

-- or via config table
Window.Topbar:Button({
    Name        = "Alerts",
    Icon        = "lucide:bell",
    Callback    = function() end,
    LayoutOrder = 990,
})
```

---

## Tag (topbar center)

```lua
Window:Tag({ Title = "BETA", Color = Color3.fromHex("#f59e0b") })
```

---

## Divider (sidebar)

```lua
Window:Divider()
```

---

## Dialog

```lua
Window:Dialog({
    Title   = "Confirm",
    Content = "Are you sure?",
    Icon    = "lucide:alert-triangle",
    Width   = 320,
    Buttons = {
        {
            Title    = "Yes",
            Icon     = "lucide:check",
            Variant  = "Primary",
            Callback = function() end,
        },
        {
            Title    = "No",
            Variant  = "Secondary",
            Callback = function() end,
        },
    },
})
```
