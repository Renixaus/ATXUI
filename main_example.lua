--[[
    ATX_UI — Full Feature Example
    https://github.com/Renixaus/ATXUI
]]

local ATXUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/main/dist/main.lua"))()

-- ──────────────────────────────────────────────────
--  Theme
-- ──────────────────────────────────────────────────

ATXUI:AddTheme({
    Name                = "Custom",
    Background          = Color3.fromHex("#0f0f14"),
    MainBackground      = Color3.fromHex("#13131a"),
    ElementBackground   = Color3.fromHex("#1a1a24"),
    Accent              = Color3.fromHex("#7c6af7"),
    Toggle              = Color3.fromHex("#7c6af7"),
    Checkbox            = Color3.fromHex("#7c6af7"),
    Button              = Color3.fromHex("#7c6af7"),
    Text                = Color3.fromHex("#e8e8f0"),
    SubText             = Color3.fromHex("#8888aa"),
    PlaceholderText     = Color3.fromHex("#55556a"),
    TabBackground       = Color3.fromHex("#1a1a24"),
    TabTitle            = Color3.fromHex("#e8e8f0"),
})

ATXUI:SetTheme("Dark")

-- ──────────────────────────────────────────────────
--  Window
-- ──────────────────────────────────────────────────

local Window = ATXUI:CreateWindow({
    Title        = "ATX_UI",
    Author       = "Full Feature Demo",
    SideBarWidth = 200,
    Size         = UDim2.fromOffset(580, 460),
    Folder       = "ATX_UI_Demo",
    Transparent  = true,
    Acrylic      = false,
    ToggleKey    = Enum.KeyCode.RightControl,
    Topbar       = { Height = 52, ButtonsType = "Default" },
})

-- ──────────────────────────────────────────────────
--  State
-- ──────────────────────────────────────────────────

local State = {
    Speed       = 16,
    Fly         = false,
    ESP         = false,
    Theme       = "Dark",
    WalkBind    = Enum.KeyCode.V,
    TargetColor = Color3.fromRGB(120, 100, 255),
}

-- ──────────────────────────────────────────────────
--  Tab 1 — Player
-- ──────────────────────────────────────────────────

local PlayerTab = Window:Tab({
    Title         = "Player",
    Icon          = "lucide:user",
    ShowTabTitle  = true,
    TabTitleAlign = "Left",
    CustomEmptyPage = { Icon = "lucide:user", Title = "No elements yet" },
})

local MovementSection = PlayerTab:Section({
    Title  = "Movement",
    Icon   = "lucide:footprints",
    Opened = true,
    Box    = true,
})

MovementSection:Toggle({
    Title    = "Fly",
    Desc     = "Toggle fly mode",
    Icon     = "lucide:plane",
    Value    = State.Fly,
    Callback = function(v)
        State.Fly = v
        ATXUI:Notify({
            Title    = "Fly",
            Content  = v and "Enabled" or "Disabled",
            Icon     = "lucide:plane",
            Duration = 2,
        })
    end,
})

MovementSection:Slider({
    Title     = "Walk Speed",
    Desc      = "Default is 16",
    Value     = { Min = 1, Max = 100, Default = State.Speed },
    Step      = 1,
    IsTooltip = true,
    IsTextbox = true,
    Callback  = function(v)
        State.Speed = v
        local lp = game:GetService("Players").LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = v
        end
    end,
})

MovementSection:Slider({
    Title     = "Jump Power",
    Value     = { Min = 0, Max = 200, Default = 50 },
    Step      = 5,
    IsTooltip = true,
    Icons     = { From = "lucide:arrow-down", To = "lucide:arrow-up" },
    Callback  = function(v)
        local lp = game:GetService("Players").LocalPlayer
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = v
        end
    end,
})

MovementSection:Keybind({
    Title     = "Walk Bind",
    Desc      = "Keybind to toggle walk",
    Value     = State.WalkBind,
    CanChange = true,
    Callback  = function(key)
        State.WalkBind = key
    end,
})

PlayerTab:Divider()

local AppearSection = PlayerTab:Section({
    Title  = "Appearance",
    Icon   = "lucide:palette",
    Opened = true,
    Box    = true,
})

AppearSection:Colorpicker({
    Title    = "Chams Color",
    Desc     = "Color applied to ESP chams",
    Default  = State.TargetColor,
    Callback = function(color)
        State.TargetColor = color
    end,
})

AppearSection:Colorpicker({
    Title        = "Chams (with Alpha)",
    Default      = Color3.fromRGB(255, 80, 80),
    Transparency = 0.4,
    Callback     = function(color, transparency) end,
})

AppearSection:Toggle({
    Title    = "Noclip",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(v) end,
})

-- ──────────────────────────────────────────────────
--  Tab 2 — Visuals
-- ──────────────────────────────────────────────────

local VisualsTab = Window:Tab({
    Title        = "Visuals",
    Icon         = "lucide:eye",
    ShowTabTitle = true,
})

VisualsTab:Toggle({
    Title    = "ESP",
    Icon     = "lucide:scan",
    Value    = State.ESP,
    Callback = function(v) State.ESP = v end,
})

VisualsTab:Slider({
    Title     = "ESP Distance",
    Value     = { Min = 10, Max = 1000, Default = 500 },
    Step      = 10,
    IsTextbox = true,
    Callback  = function(v) end,
})

VisualsTab:Dropdown({
    Title    = "ESP Mode",
    Values   = { "Box", "Skeleton", "Corner Box", "Head Dot" },
    Value    = "Box",
    Callback = function(v) end,
})

VisualsTab:Dropdown({
    Title            = "Highlight Players",
    Values           = { "Friends", "Enemies", "Everyone" },
    Multi            = true,
    Value            = { "Everyone" },
    SearchBarEnabled = true,
    Callback         = function(v) end,
})

VisualsTab:Divider()

VisualsTab:Image({
    Image       = "rbxassetid://6031280882",
    AspectRatio = "16:9",
    Radius      = 8,
})

-- ──────────────────────────────────────────────────
--  Tab 3 — Misc
-- ──────────────────────────────────────────────────

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon  = "lucide:settings",
})

local ButtonGroup = MiscTab:Group()

ButtonGroup:Button({
    Title    = "Rejoin",
    Icon     = "lucide:refresh-cw",
    Variant  = "Secondary",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end,
})

ButtonGroup:Button({
    Title    = "Copy UserID",
    Icon     = "lucide:copy",
    Variant  = "Secondary",
    Callback = function()
        local lp = game:GetService("Players").LocalPlayer
        setclipboard(tostring(lp.UserId))
        ATXUI:Notify({ Title = "Copied", Content = tostring(lp.UserId), Duration = 2 })
    end,
})

MiscTab:Divider()

local HRow = MiscTab:HStack()

HRow:Toggle({ Title = "Anti-AFK",  Value = true,  Callback = function(v) end })
HRow:Toggle({ Title = "Auto-Farm", Value = false, Callback = function(v) end })
HRow:Toggle({ Title = "Inf Yield", Value = false, Callback = function(v) end })

MiscTab:Divider()

MiscTab:Input({
    Title       = "Server Join",
    Desc        = "Enter a Place ID",
    Placeholder = "Place ID...",
    Icon        = "lucide:server",
    Callback    = function(v)
        local id = tonumber(v)
        if id then
            game:GetService("TeleportService"):Teleport(id)
        end
    end,
})

MiscTab:Input({
    Title       = "Notes",
    Placeholder = "Write something...",
    Type        = "Textarea",
    Callback    = function(v) end,
})

MiscTab:Divider()

MiscTab:Dropdown({
    Title    = "UI Theme",
    Values   = { "Dark", "Light", "Custom" },
    Value    = State.Theme,
    Callback = function(v)
        State.Theme = v
        ATXUI:SetTheme(v)
    end,
})

MiscTab:Divider()

MiscTab:Paragraph({
    Title   = "ATX_UI",
    Desc    = "A Roblox UI library with smooth micro-animations, glass effects, and a full element suite.",
    Buttons = {
        { Title = "GitHub", Icon = "lucide:github",    Callback = function() setclipboard("https://github.com/Renixaus/ATXUI") end },
        { Title = "Copy",   Icon = "lucide:clipboard", Callback = function() setclipboard("https://github.com/Renixaus/ATXUI") end },
    },
})

-- ──────────────────────────────────────────────────
--  Tab 4 — Info
-- ──────────────────────────────────────────────────

local InfoTab = Window:Tab({
    Title = "Info",
    Icon  = "lucide:info",
})

InfoTab:Code({
    Title = "Quick Start",
    Code  = [[local UI = loadstring(game:HttpGet(
  "https://raw.githubusercontent.com/Renixaus/ATXUI/refs/heads/main/dist/main.lua"
))()

local Win = UI:CreateWindow({ Title = "My Script" })
local Tab = Win:Tab({ Title = "Main", Icon = "lucide:home" })
Tab:Toggle({ Title = "Feature", Callback = function(v) end })
]],
})

InfoTab:Divider()

local VCol = InfoTab:VStack()

VCol:Button({
    Title    = "Send Notification",
    Icon     = "lucide:bell",
    Variant  = "Primary",
    Callback = function()
        ATXUI:Notify({
            Title    = "Hello!",
            Content  = "This is a notification from ATX_UI.",
            Icon     = "lucide:sparkles",
            Duration = 4,
        })
    end,
})

VCol:Button({
    Title    = "Open Dialog",
    Icon     = "lucide:message-square",
    Variant  = "Secondary",
    Callback = function()
        Window:Dialog({
            Title   = "Confirm Action",
            Content = "Are you sure you want to proceed?",
            Buttons = {
                {
                    Title    = "Confirm",
                    Icon     = "lucide:check",
                    Variant  = "Primary",
                    Callback = function()
                        ATXUI:Notify({ Title = "Confirmed", Duration = 2 })
                    end,
                },
                {
                    Title    = "Cancel",
                    Icon     = "lucide:x",
                    Variant  = "Secondary",
                    Callback = function() end,
                },
            },
        })
    end,
})

-- ──────────────────────────────────────────────────
--  Init
-- ──────────────────────────────────────────────────

PlayerTab:Select()

task.delay(0.5, function()
    ATXUI:Notify({
        Title    = "ATX_UI Loaded",
        Content  = "Press RCtrl to toggle the UI.",
        Icon     = "lucide:sparkles",
        Duration = 5,
    })
end)
