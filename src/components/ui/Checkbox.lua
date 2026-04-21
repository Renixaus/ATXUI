--!strict
local Checkbox = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

function Checkbox.New(Value, Icon, IconSize, Parent, Callback, Config)
	local Checkbox = {}

	Icon = Icon or "sfsymbols:checkmark"

	local Radius = 9

	local IconCheckboxFrame = Creator.Image(
		Icon,
		Icon,
		0,
		(Config and Config.Window.Folder or "Temp"),
		"Checkbox",
		true,
		false,
		"CheckboxIcon"
	)
	IconCheckboxFrame.Size = UDim2.new(1, -26 + IconSize, 1, -26 + IconSize)
	IconCheckboxFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	IconCheckboxFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

	local CheckboxFrame = Creator.NewRoundFrame(Radius, "Squircle", {
		ImageTransparency = 0.85, -- 0
		ThemeTag = {
			ImageColor3 = "Text",
		},
		Parent = Parent,
		Size = UDim2.new(0, 26, 0, 26),
	}, {
		Creator.NewRoundFrame(Radius, "Squircle", {
			Size = UDim2.new(1, 0, 1, 0),
			Name = "Layer",
			ThemeTag = {
				ImageColor3 = "Checkbox",
			},
			ImageTransparency = 1, -- 0
		}),
		Creator.NewRoundFrame(Radius, "Glass-1.4", {
			Size = UDim2.new(1, 0, 1, 0),
			Name = "Stroke",
			ThemeTag = {
				ImageColor3 = "CheckboxBorder",
				ImageTransparency = "CheckboxBorderTransparency",
			},
		}, {
			-- New("UIGradient", {
			--     Rotation = 90,
			--     Transparency = NumberSequence.new({
			--         NumberSequenceKeypoint.new(0, 0),
			--         NumberSequenceKeypoint.new(1, 1),
			--     })
			-- })
		}),

		IconCheckboxFrame,
	}, true)

	local CheckboxScale = New("UIScale", { Scale = 1 })
	CheckboxScale.Parent = CheckboxFrame

	function Checkbox:Set(Toggled)
		if Toggled then
			Tween(CheckboxFrame.Layer, 0.06, { ImageTransparency = 0 }):Play()
			Tween(IconCheckboxFrame.ImageLabel, 0.06, { ImageTransparency = 0 }):Play()
			Tween(CheckboxScale, 0.12, { Scale = 1.15 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			task.delay(0.12, function()
				Tween(CheckboxScale, 0.22, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			end)
		else
			Tween(CheckboxFrame.Layer, 0.06, { ImageTransparency = 1 }):Play()
			Tween(IconCheckboxFrame.ImageLabel, 0.06, { ImageTransparency = 1 }):Play()
			Tween(CheckboxScale, 0.15, { Scale = 0.88 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			task.delay(0.15, function()
				Tween(CheckboxScale, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			end)
		end

		task.spawn(function()
			if Callback then
				Creator.SafeCallback(Callback, Toggled)
			end
		end)
	end

	return CheckboxFrame, Checkbox
end

return Checkbox
