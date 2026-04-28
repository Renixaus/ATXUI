--!strict
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local LocalizationService = cloneref(game:GetService("LocalizationService"))
local HttpService = cloneref(game:GetService("HttpService"))

local RenderStepped = RunService.Heartbeat

local IconsURL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"

local Icons
if RunService:IsStudio() or not writefile then
	Icons = require("./Icons")
else
	Icons = loadstring(
		game.HttpGetAsync and game:HttpGetAsync(IconsURL) or HttpService:GetAsync(IconsURL) --studio
	)()
end

Icons.SetIconsType("lucide")

local ATXUI

local Creator
Creator = {
	Font = "rbxassetid://12187365364",
	Localization = nil,
	CanDraggable = true,
	Theme = nil,
	Themes = nil,
	Icons = Icons,
	Signals = {},
	ObjectSignals = {},
	Objects = {},
	LocalizationObjects = {},
	FontObjects = {},
	Language = string.match(LocalizationService.SystemLocaleId, "^[a-z]+"),
	Request = http_request or (syn and syn.request) or request,
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = "Sibling",
		},
		CanvasGroup = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
		},
		Frame = {
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.new(1, 1, 1),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			RichText = true,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			AutoButtonColor = false,
		},
		UIListLayout = {
			SortOrder = "LayoutOrder",
		},
		ScrollingFrame = {
			ScrollBarImageTransparency = 1,
			BorderSizePixel = 0,
		},
		VideoFrame = {
			BorderSizePixel = 0,
		},
	},
	Colors = {
		Red = "#e53935",
		Orange = "#f57c00",
		Green = "#43a047",
		Blue = "#039be5",
		White = "#ffffff",
		Grey = "#484848",
	},
	ThemeFallbacks = nil,
	Shapes = {
		["Square"] = "rbxassetid://82909646051652",
		["Square-Outline"] = "rbxassetid://72946211851948",

		["Squircle"] = "rbxassetid://80999662900595",
		["SquircleOutline"] = "rbxassetid://117788349049947",
		["Squircle-Outline"] = "rbxassetid://117817408534198",

		["SquircleOutline2"] = "rbxassetid://117817408534198",

		["Shadow-sm"] = "rbxassetid://84825982946844",

		["Squircle-TL-TR"] = "rbxassetid://73569156276236",
		["Squircle-BL-BR"] = "rbxassetid://93853842912264",
		["Squircle-TL-TR-Outline"] = "rbxassetid://136702870075563",
		["Squircle-BL-BR-Outline"] = "rbxassetid://75035847706564",

		["Glass-0.7"] = "rbxassetid://79047752995006",
		["Glass-1"] = "rbxassetid://97324581055162",
		["Glass-1.4"] = "rbxassetid://95071123641270",
	},
	ThemeChangeCallbacks = {},
}

function Creator.Init(WindUITable)
	ATXUI = WindUITable

	Creator.ThemeFallbacks = require("../themes/Fallbacks")(Creator)
end

function Creator.AddSignal(Signal, Function)
	local conn = Signal:Connect(Function)
	table.insert(Creator.Signals, conn)
	return conn
end

function Creator.DisconnectAll()
	for idx, signal in next, Creator.Signals do
		local Connection = table.remove(Creator.Signals, idx)
		Connection:Disconnect()
	end
end

function Creator.SafeCallback(Function, ...)
	if not Function then
		return
	end

	local Success, Event = pcall(Function, ...)
	if not Success then
		if ATXUI and ATXUI.Window and ATXUI.Window.Debug then
			local _, i = Event:find(":%d+: ")

			warn("[ ATXUI: DEBUG Mode ] " .. Event)

			return ATXUI:Notify({
				Title = "DEBUG Mode: Error",
				Content = not i and Event or Event:sub(i + 1),
				Duration = 8,
			})
		end
	end
end

function Creator.Gradient(stops, props)
	if ATXUI and ATXUI.Gradient then
		return ATXUI:Gradient(stops, props)
	end

	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)
			table.insert(colorSequence, ColorSequenceKeypoint.new(position, stop.Color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, stop.Transparency or 0))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		error("ColorSequence requires at least 2 keypoints")
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

function Creator.SetTheme(Theme)
	local PreviousTheme = Creator.Theme
	Creator.Theme = Theme
	Creator.UpdateTheme(nil, false)

	for _, Callback in next, Creator.ThemeChangeCallbacks do
		Creator.SafeCallback(Callback, Theme, PreviousTheme)
	end
end

function Creator.AddFontObject(Object)
	table.insert(Creator.FontObjects, Object)
	Creator.UpdateFont(Creator.Font)
end

function Creator.UpdateFont(FontId)
	Creator.Font = FontId
	for _, Obj in next, Creator.FontObjects do
		Obj.FontFace = Font.new(FontId, Obj.FontFace.Weight, Obj.FontFace.Style)
	end
end

function Creator.GetThemeProperty(Property, Theme)
	local function getValue(prop, themeTable)
		local value = themeTable[prop]

		if value == nil then
			return nil
		end

		if typeof(value) == "string" and string.sub(value, 1, 1) == "#" then
			return Color3.fromHex(value)
		end

		if typeof(value) == "Color3" then
			return value
		end

		if typeof(value) == "number" then
			return value
		end

		if typeof(value) == "table" and value.Color and value.Transparency then
			return value
		end

		if typeof(value) == "function" then
			return value(themeTable)
		end

		return value
	end

	local value = getValue(Property, Theme)
	if value ~= nil then
		if typeof(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referencedValue = Creator.GetThemeProperty(value, Theme)
			if referencedValue ~= nil then
				return referencedValue
			end
		else
			return value
		end
	end

	local fallbackProperty = Creator.ThemeFallbacks[Property]
	if fallbackProperty ~= nil then
		if typeof(fallbackProperty) == "string" and string.sub(fallbackProperty, 1, 1) ~= "#" then
			return Creator.GetThemeProperty(fallbackProperty, Theme)
		else
			return getValue(Property, { [Property] = fallbackProperty })
		end
	end

	value = getValue(Property, Creator.Themes["Dark"])
	if value ~= nil then
		if typeof(value) == "string" and string.sub(value, 1, 1) ~= "#" then
			local referencedValue = Creator.GetThemeProperty(value, Creator.Themes["Dark"])
			if referencedValue ~= nil then
				return referencedValue
			end
		else
			return value
		end
	end

	if fallbackProperty ~= nil then
		if typeof(fallbackProperty) == "string" and string.sub(fallbackProperty, 1, 1) ~= "#" then
			return Creator.GetThemeProperty(fallbackProperty, Creator.Themes["Dark"])
		else
			return getValue(Property, { [Property] = fallbackProperty })
		end
	end

	return nil
end

function Creator.AddThemeObject(Object, Properties, skipUpdate)
	if Creator.Objects[Object] then
		for prop, value in pairs(Properties) do
			Creator.Objects[Object].Properties[prop] = value
		end
	else
		Creator.Objects[Object] = { Object = Object, Properties = Properties }
	end

	if not skipUpdate then
		Creator.UpdateTheme(Object, false)
	end
	return Object
end

function Creator.AddLangObject(idx)
	local currentObj = Creator.LocalizationObjects[idx]
	if not currentObj then
		return
	end

	local Object = currentObj.Object

	Creator.SetLangForObject(idx)

	return Object
end

function Creator.UpdateTheme(TargetObject, isTween, isTweenTarget, Duration, EasingStyle, EasingDirection)
	local function ApplyTheme(objData)
		for Property, ColorKey in pairs(objData.Properties or {}) do
			local value = Creator.GetThemeProperty(ColorKey, Creator.Theme)
			if value ~= nil then
				if typeof(value) == "Color3" then
					local gradient = objData.Object:FindFirstChild("LibraryGradient")
					if gradient then
						gradient:Destroy()
					end

					if isTweenTarget then
						Creator.Tween(
							objData.Object,
							Duration or 0.2,
							{ [Property] = value },
							EasingStyle or Enum.EasingStyle.Quint,
							EasingDirection or Enum.EasingDirection.Out
						):Play()
					elseif isTween then
						Creator.Tween(objData.Object, 0.08, { [Property] = value }):Play()
					else
						objData.Object[Property] = value
					end
				elseif typeof(value) == "table" and value.Color and value.Transparency then
					objData.Object[Property] = Color3.new(1, 1, 1)

					local gradient = objData.Object:FindFirstChild("LibraryGradient")
					if not gradient then
						gradient = Instance.new("UIGradient")
						gradient.Name = "LibraryGradient"
						gradient.Parent = objData.Object
					end

					gradient.Color = value.Color
					gradient.Transparency = value.Transparency

					for prop, propValue in pairs(value) do
						if prop ~= "Color" and prop ~= "Transparency" and gradient[prop] ~= nil then
							gradient[prop] = propValue
						end
					end
				elseif typeof(value) == "number" then
					if isTweenTarget then
						Creator.Tween(
							objData.Object,
							Duration or 0.2,
							{ [Property] = value },
							EasingStyle or Enum.EasingStyle.Quint,
							EasingDirection or Enum.EasingDirection.Out
						):Play()
					elseif isTween then
						Creator.Tween(objData.Object, 0.08, { [Property] = value }):Play()
					else
						objData.Object[Property] = value
					end
				end
			else
				local gradient = objData.Object:FindFirstChild("LibraryGradient")
				if gradient then
					gradient:Destroy()
				end
			end
		end
	end

	if TargetObject then
		local objData = Creator.Objects[TargetObject]
		if objData then
			ApplyTheme(objData)
		end
	else
		for _, objData in pairs(Creator.Objects) do
			ApplyTheme(objData)
		end
	end
end

function Creator.SetThemeTag(Object, ThemeTag, Duration, EasingStyle, EasingDirection)
	Creator.AddThemeObject(Object, ThemeTag)
	Creator.UpdateTheme(Object, false, true, Duration, EasingStyle, EasingDirection)
end

function Creator.SetLangForObject(index)
	if Creator.Localization and Creator.Localization.Enabled then
		local data = Creator.LocalizationObjects[index]
		if not data then
			return
		end

		local obj = data.Object
		local translationId = data.TranslationId

		local translations = Creator.Localization.Translations[Creator.Language]
		if translations and translations[translationId] then
			obj.Text = translations[translationId]
		else
			local enTranslations = Creator.Localization
					and Creator.Localization.Translations
					and Creator.Localization.Translations.en
				or nil
			if enTranslations and enTranslations[translationId] then
				obj.Text = enTranslations[translationId]
			else
				obj.Text = "[" .. translationId .. "]"
			end
		end
	end
end

function Creator:ChangeTranslationKey(object, newKey)
	if Creator.Localization and Creator.Localization.Enabled then
		local ParsedKey = string.match(newKey, "^" .. Creator.Localization.Prefix .. "(.+)")
		if ParsedKey then
			for i, data in ipairs(Creator.LocalizationObjects) do
				if data.Object == object then
					data.TranslationId = ParsedKey
					Creator.SetLangForObject(i)
					return
				end
			end

			table.insert(Creator.LocalizationObjects, {
				TranslationId = ParsedKey,
				Object = object,
			})
			Creator.SetLangForObject(#Creator.LocalizationObjects)
		end
	end
end

function Creator.UpdateLang(newLang)
	if newLang then
		Creator.Language = newLang
	end

	for i = 1, #Creator.LocalizationObjects do
		local data = Creator.LocalizationObjects[i]
		if data.Object and data.Object.Parent ~= nil then
			Creator.SetLangForObject(i)
		else
			Creator.LocalizationObjects[i] = nil
		end
	end
end

function Creator.SetLanguage(lang)
	Creator.Language = lang
	Creator.UpdateLang()
end

function Creator.Icon(Icon, formatdefault)
	return Icons.Icon2(Icon, nil, formatdefault ~= false)
end

function Creator.AddIcons(packName, iconsData)
	return Icons.AddIcons(packName, iconsData)
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
		if Creator.Localization and Creator.Localization.Enabled and Name == "Text" then
			local TranslationId = string.match(Value, "^" .. Creator.Localization.Prefix .. "(.+)")
			if TranslationId then
				local currentId = #Creator.LocalizationObjects + 1
				Creator.LocalizationObjects[currentId] = { TranslationId = TranslationId, Object = Object }

				Creator.SetLangForObject(currentId)
			end
		end
	end

	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	if Properties and Properties.ThemeTag then
		Creator.AddThemeObject(Object, Properties.ThemeTag)
	end
	if Properties and Properties.FontFace then
		Creator.AddFontObject(Object)
	end
	return Object
end

function Creator.Tween(Object, Time, Properties, ...)
	return TweenService:Create(Object, TweenInfo.new(Time, ...), Properties)
end

function Creator.NewRoundFrame(Radius, Type, Properties, Children, isButton, ReturnTable)
	local function getImageForType(shapeType)
		return Creator.Shapes[shapeType]
	end

	local function getSliceCenterForType(shapeType)
		return not table.find({ "Shadow-sm", "Glass-0.7", "Glass-1", "Glass-1.4" }, shapeType)
				and Rect.new(512 / 2, 512 / 2, 512 / 2, 512 / 2)
			or Rect.new(512, 512, 512, 512)
	end

	local Image = Creator.New(isButton and "ImageButton" or "ImageLabel", {
		Image = getImageForType(Type),
		ScaleType = "Slice",
		SliceCenter = getSliceCenterForType(Type),
		SliceScale = 1,
		BackgroundTransparency = 1,
		ThemeTag = Properties.ThemeTag and Properties.ThemeTag,
	}, Children)

	for k, v in pairs(Properties or {}) do
		if k ~= "ThemeTag" then
			Image[k] = v
		end
	end

	local function UpdateSliceScale(newRadius)
		local sliceScale = not table.find({ "Shadow-sm", "Glass-0.7", "Glass-1", "Glass-1.4" }, Type)
				and (newRadius / (512 / 2))
			or (newRadius / 512)
		Image.SliceScale = math.max(sliceScale, 0.0001)
	end

	local Wrapper = {}

	function Wrapper:SetRadius(newRadius)
		UpdateSliceScale(newRadius)
	end

	function Wrapper:SetType(newType)
		Type = newType
		Image.Image = getImageForType(newType)
		Image.SliceCenter = getSliceCenterForType(newType)
		UpdateSliceScale(Radius)
	end

	function Wrapper:UpdateShape(newRadius, newType)
		if newType then
			Type = newType
			Image.Image = getImageForType(newType)
			Image.SliceCenter = getSliceCenterForType(newType)
		end
		if newRadius then
			Radius = newRadius
		end
		UpdateSliceScale(Radius)
	end

	function Wrapper:GetRadius()
		return Radius
	end

	function Wrapper:GetType()
		return Type
	end

	UpdateSliceScale(Radius)

	return Image, ReturnTable and Wrapper or nil
end

local New = Creator.New
local Tween = Creator.Tween

function Creator.SetDraggable(can)
	Creator.CanDraggable = can
end

function Creator.Drag(mainFrame, dragFrames, ondrag)
	local currentDragFrame = nil
	local dragging, dragStart, startPos
	local dragStartInput = nil
	local endConnection = nil
	local DragModule = {
		CanDraggable = true,
	}

	if not dragFrames or typeof(dragFrames) ~= "table" then
		dragFrames = { mainFrame }
	end

	local MIN_ON_SCREEN = 40

	local function getViewportSize()
		local parent = mainFrame.Parent
		if parent and parent:IsA("GuiBase2d") then
			local abs = parent.AbsoluteSize
			if abs and abs.X > 0 and abs.Y > 0 then
				return abs
			end
		end
		local camera = workspace.CurrentCamera
		if camera then
			return camera.ViewportSize
		end
		return Vector2.new(1920, 1080)
	end

	local function stopDragging()
		if not dragging then
			return
		end
		dragging = false
		currentDragFrame = nil
		dragStartInput = nil
		if endConnection then
			endConnection:Disconnect()
			endConnection = nil
		end
		if ondrag and typeof(ondrag) == "function" then
			ondrag(false, nil)
		end
	end

	local function update(input)
		if not dragging or not DragModule.CanDraggable then
			return
		end

		local delta = input.Position - dragStart
		local absSize = mainFrame.AbsoluteSize
		local viewport = getViewportSize()

		local newOffsetX = startPos.X.Offset + delta.X
		local newOffsetY = startPos.Y.Offset + delta.Y

		-- Clamp so at least MIN_ON_SCREEN px of the window stays visible on each edge.
		-- Position offset lives in the parent's absolute coordinate space; anchor/scale
		-- components are preserved from startPos.
		local anchoredLeft = -(startPos.X.Scale * viewport.X) - (mainFrame.AnchorPoint.X * absSize.X)
		local anchoredTop = -(startPos.Y.Scale * viewport.Y) - (mainFrame.AnchorPoint.Y * absSize.Y)

		local minX = anchoredLeft + MIN_ON_SCREEN - absSize.X
		local maxX = anchoredLeft + viewport.X - MIN_ON_SCREEN
		local minY = anchoredTop + MIN_ON_SCREEN - absSize.Y
		local maxY = anchoredTop + viewport.Y - MIN_ON_SCREEN

		if minX < maxX then
			newOffsetX = math.clamp(newOffsetX, minX, maxX)
		end
		if minY < maxY then
			newOffsetY = math.clamp(newOffsetY, minY, maxY)
		end

		-- Direct assignment — no per-frame tween. Feels tighter, avoids tweens fighting.
		mainFrame.Position = UDim2.new(startPos.X.Scale, newOffsetX, startPos.Y.Scale, newOffsetY)
	end

	for _, dragFrame in pairs(dragFrames) do
		dragFrame.InputBegan:Connect(function(input)
			if
				(
					input.UserInputType == Enum.UserInputType.MouseButton1
					or input.UserInputType == Enum.UserInputType.Touch
				) and DragModule.CanDraggable
			then
				if currentDragFrame == nil then
					currentDragFrame = dragFrame
					dragging = true
					dragStart = input.Position
					startPos = mainFrame.Position
					dragStartInput = input

					if ondrag and typeof(ondrag) == "function" then
						ondrag(true, currentDragFrame)
					end

					-- Keep reference so we can disconnect on End and avoid leaking
					-- one connection per tap.
					if endConnection then
						endConnection:Disconnect()
						endConnection = nil
					end
					endConnection = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							stopDragging()
						end
					end)
				end
			end
		end)
	end

	-- Single global motion handler. The per-frame dragFrame.InputChanged subscription
	-- was removed: it double-fired with this one on Touch and caused jitter on mobile.
	UserInputService.InputChanged:Connect(function(input)
		if not dragging or currentDragFrame == nil then
			return
		end
		-- Ignore motion from any simultaneous Touch input other than the one
		-- that started the drag (mobile can report multiple touches).
		if input.UserInputType == Enum.UserInputType.Touch then
			if dragStartInput == nil or input ~= dragStartInput then
				return
			end
			update(input)
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)

	function DragModule:Set(v)
		DragModule.CanDraggable = v
		if not v then
			stopDragging()
		end
	end

	return DragModule
end

Icons.Init(New, "Icon")

function Creator.SanitizeFilename(url)
	local filename = url:match("([^/]+)$") or url

	filename = filename:gsub("%.[^%.]+$", "")

	filename = filename:gsub("[^%w%-_]", "_")

	if #filename > 50 then
		filename = filename:sub(1, 50)
	end

	return filename
end

function Creator.Image(Img, Name, Corner, Folder, Type, IsThemeTag, Themed, ThemeTagName)
	Folder = Folder or "Temp"
	Name = Creator.SanitizeFilename(Name)

	local ImageFrame = New("Frame", {
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScaleType = "Crop",
			ThemeTag = (Creator.Icon(Img) or Themed) and {
				ImageColor3 = IsThemeTag and (ThemeTagName or "Icon") or nil,
			} or nil,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, Corner),
			}),
		}),
	})
	if Creator.Icon(Img) then
		ImageFrame.ImageLabel:Destroy()

		local IconLabel = Icons.Image({
			Icon = Img,
			Size = UDim2.new(1, 0, 1, 0),
			Colors = {
				(IsThemeTag and (ThemeTagName or "Icon") or false),
				"Button",
			},
		}).IconFrame
		-- Rename to "ImageLabel" so call sites accessing ImageFrame.ImageLabel keep working.
		-- Icons.Image(...).IconFrame is itself an ImageLabel (see Icons.lua), so renaming preserves the public shape.
		IconLabel.Name = "ImageLabel"
		IconLabel.Parent = ImageFrame
	elseif string.find(Img, "http") and not string.find(Img, "roblox.com") then
		local FileName = "ATXUI/" .. Folder .. "/assets/." .. Type .. "-" .. Name .. ".png"
		local success, response = pcall(function()
			task.spawn(function()
				local response = Creator.Request
						and Creator.Request({
							Url = Img,
							Method = "GET",
						}).Body
					or {}

				if not RunService:IsStudio() and writefile then
					writefile(FileName, response)
				end
				--ImageFrame.ImageLabel.Image = getcustomasset(FileName)

				local assetSuccess, asset = pcall(getcustomasset, FileName)
				if assetSuccess then
					ImageFrame.ImageLabel.Image = asset
				else
					warn(
						string.format(
							"[ ATXUI.Creator ] Failed to load custom asset '%s': %s",
							FileName,
							tostring(asset)
						)
					)
					ImageFrame:Destroy()

					return
				end
			end)
		end)
		if not success then
			warn(
				"[ ATXUI.Creator ]  '" .. identifyexecutor()
					or "Studio" .. "' doesnt support the URL Images. Error: " .. response
			)

			ImageFrame:Destroy()
		end
	elseif Img == "" then
		ImageFrame.Visible = false
	else
		ImageFrame.ImageLabel.Image = Img
	end

	return ImageFrame
end

function Creator.Color3ToHSB(color)
	local r, g, b = color.R, color.G, color.B
	local max = math.max(r, g, b)
	local min = math.min(r, g, b)
	local delta = max - min

	local h = 0
	if delta ~= 0 then
		if max == r then
			h = (g - b) / delta % 6
		elseif max == g then
			h = (b - r) / delta + 2
		else
			h = (r - g) / delta + 4
		end
		h = h * 60
	else
		h = 0
	end

	local s = (max == 0) and 0 or (delta / max)
	local v = max

	return {
		h = math.floor(h + 0.5),
		s = s,
		b = v,
	}
end

function Creator.GetPerceivedBrightness(color)
	local r = color.R
	local g = color.G
	local b = color.B
	return 0.299 * r + 0.587 * g + 0.114 * b
end

function Creator.GetTextColorForHSB(color, contrast)
	local hsb = Creator.Color3ToHSB(color)
	local h, s, b = hsb.h, hsb.s, hsb.b
	if Creator.GetPerceivedBrightness(color) > (contrast or 0.5) then
		return Color3.fromHSV(h / 360, 0, 0.05)
	else
		return Color3.fromHSV(h / 360, 0, 0.98)
	end
end

function Creator.GetAverageColor(gradient)
	local r, g, b = 0, 0, 0
	local keypoints = gradient.Color.Keypoints
	for _, k in ipairs(keypoints) do
		-- bruh
		r = r + k.Value.R
		g = g + k.Value.G
		b = b + k.Value.B
	end
	local n = #keypoints
	return Color3.new(r / n, g / n, b / n)
end

function Creator:GenerateUniqueID()
	return HttpService:GenerateGUID(false)
end

function Creator:OnThemeChange(callback)
	if typeof(callback) ~= "function" then
		return
	end

	local id = HttpService:GenerateGUID(false)
	Creator.ThemeChangeCallbacks[id] = callback

	return {
		Disconnect = function()
			Creator.ThemeChangeCallbacks[id] = nil
		end,
	}
end

function Creator:AddColor(base, add, weight)
	weight = math.clamp(weight or 1, 0, 1)
	if typeof(add) == "string" then
		add = Color3.fromHex(add)
	end

	return function(theme)
		local baseColor
		if typeof(base) == "string" and string.sub(base, 1, 1) ~= "#" then
			baseColor = Creator.GetThemeProperty(base, theme)
		elseif typeof(base) == "string" then
			baseColor = Color3.fromHex(base)
		else
			baseColor = base
		end

		if not baseColor or typeof(baseColor) ~= "Color3" then
			return nil
		end

		return Color3.new(
			math.clamp(baseColor.R + add.R * weight, 0, 1),
			math.clamp(baseColor.G + add.G * weight, 0, 1),
			math.clamp(baseColor.B + add.B * weight, 0, 1)
		)
	end
end

return Creator
 and string.sub(base, 1, 1) ~= "#" then
			baseColor = Creator.GetThemeProperty(base, theme)
		elseif typeof(base) == "string" then
			baseColor = Color3.fromHex(base)
		else
			baseColor = base
		end

		if not baseColor or typeof(baseColor) ~= "Color3" then
			return nil
		end

		return Color3.new(
			math.clamp(baseColor.R + add.R * weight, 0, 1),
			math.clamp(baseColor.G + add.G * weight, 0, 1),
			math.clamp(baseColor.B + add.B * weight, 0, 1)
		)
	end
end

return Creator
