--!strict
local ATXUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

ATXUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	ATXUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = ATXUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = ATXUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local UIScaleObj = New("UIScale", {
	Scale = ATXUI.UIScale,
})

ATXUI.UIScaleObj = UIScaleObj

ATXUI.ScreenGui = New("ScreenGui", {
	Name = "ATXUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = -99999,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

ATXUI.NotificationGui = New("ScreenGui", {
	Name = "ATXUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ATXUI.DropdownGui = New("ScreenGui", {
	Name = "ATXUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ATXUI.TooltipGui = New("ScreenGui", {
	Name = "ATXUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ProtectGui(ATXUI.ScreenGui)
ProtectGui(ATXUI.NotificationGui)
ProtectGui(ATXUI.DropdownGui)
ProtectGui(ATXUI.TooltipGui)

Creator.Init(ATXUI)

function ATXUI:SetParent(parent)
	if ATXUI.ScreenGui then
		ATXUI.ScreenGui.Parent = parent
	end
	if ATXUI.NotificationGui then
		ATXUI.NotificationGui.Parent = parent
	end
	if ATXUI.DropdownGui then
		ATXUI.DropdownGui.Parent = parent
	end
	if ATXUI.TooltipGui then
		ATXUI.TooltipGui.Parent = parent
	end
end
math.clamp(ATXUI.TransparencyValue, 0, 1)

local Holder = ATXUI.NotificationModule.Init(ATXUI.NotificationGui)

function ATXUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = ATXUI.Window
	--Config.ATXUI = ATXUI
	return ATXUI.NotificationModule.New(Config)
end

function ATXUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function ATXUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function ATXUI:OnThemeChange(func)
	ATXUI.OnThemeChangeFunction = func
end

function ATXUI:AddTheme(LTheme)
	ATXUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function ATXUI:SetTheme(Value)
	if ATXUI.Themes[Value] then
		ATXUI.Theme = ATXUI.Themes[Value]
		Creator.SetTheme(ATXUI.Themes[Value])

		if ATXUI.OnThemeChangeFunction then
			ATXUI.OnThemeChangeFunction(Value)
		end

		return ATXUI.Themes[Value]
	end
	return nil
end

function ATXUI:GetThemes()
	return ATXUI.Themes
end
function ATXUI:GetCurrentTheme()
	return ATXUI.Theme.Name
end
function ATXUI:GetTransparency()
	return ATXUI.Transparent or false
end
function ATXUI:GetWindowSize()
	return ATXUI.Window.UIElements.Main.Size
end
function ATXUI:Localization(LocalizationConfig)
	return ATXUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function ATXUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function ATXUI:ToggleAcrylic(Value)
	if ATXUI.Window and ATXUI.Window.AcrylicPaint and ATXUI.Window.AcrylicPaint.Model then
		ATXUI.Window.Acrylic = Value
		ATXUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function ATXUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function ATXUI:Popup(PopupConfig)
	PopupConfig.ATXUI = ATXUI
	return require("./components/popup/Init").new(PopupConfig, ATXUI.ScreenGui.Popups)
end

ATXUI.Themes = require("./themes/Init")(ATXUI, Creator)

Creator.Themes = ATXUI.Themes

ATXUI:SetTheme("Dark")
ATXUI:SetLanguage(Creator.Language)

function ATXUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if not RunService:IsStudio() and writefile then
		if not isfolder("ATXUI") then
			makefolder("ATXUI")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.ATXUI = ATXUI
	Config.Window = ATXUI.Window
	Config.Parent = ATXUI.ScreenGui.Window

	if ATXUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = ATXUI.Themes[Config.Theme or "Dark"]

	--ATXUI.Theme = Theme
	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table")
						and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = ATXUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	ATXUI.Transparent = Config.Transparent
	ATXUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     ATXUI.Transparent = Value
	--     ATXUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and ATXUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and ATXUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return ATXUI
