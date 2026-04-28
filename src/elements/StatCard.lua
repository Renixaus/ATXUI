--!strict
local Creator = require("../modules/Creator")
local New = Creator.New

local Element = {}

function Element:New(Config)
	local StatCardModule = {
		__type = "StatCard",
		Title = Config.Title or "Stat",
		Desc = Config.Desc,
		Value = Config.Value or "0",
		Icon = Config.Icon,
		Locked = Config.Locked or false,
		ElementFrame = nil,
	}

	local UICorner = Config.Window.ElementConfig.UICorner
	local UIPadding = Config.Window.ElementConfig.UIPadding

	local IconFrame
	if StatCardModule.Icon then
		IconFrame = Creator.Image(
			StatCardModule.Icon,
			StatCardModule.Title,
			0,
			Config.Window.Folder,
			"StatCard",
			true,
			false,
			"Text"
		)
		IconFrame.Size = UDim2.new(0, 18, 0, 18)
		IconFrame.ImageLabel.ImageTransparency = 0.5
	end

	local Title = New("TextLabel", {
		Text = StatCardModule.Title,
		TextSize = 14,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
		TextXAlignment = "Left",
		ThemeTag = { TextColor3 = "Text" },
		TextTransparency = 0.5,
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
	})

	local ValueLabel = New("TextLabel", {
		Text = tostring(StatCardModule.Value),
		TextSize = 28,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Bold),
		TextXAlignment = "Left",
		ThemeTag = { TextColor3 = "Text" },
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
	})

	local DescLabel
	if StatCardModule.Desc then
		DescLabel = New("TextLabel", {
			Text = StatCardModule.Desc,
			TextSize = 13,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
			TextXAlignment = "Left",
			ThemeTag = { TextColor3 = "Text" },
			TextTransparency = 0.65,
			BackgroundTransparency = 1,
			AutomaticSize = "XY",
		})
	end

	local Main = Creator.NewRoundFrame(UICorner, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = "Y",
		ThemeTag = {
			ImageColor3 = "ElementBackground",
			ImageTransparency = "ElementBackgroundTransparency",
		},
		Parent = Config.Parent,
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, UIPadding * 1.2),
			PaddingBottom = UDim.new(0, UIPadding * 1.2),
			PaddingLeft = UDim.new(0, UIPadding * 1.2),
			PaddingRight = UDim.new(0, UIPadding * 1.2),
		}),
		New("UIListLayout", {
			SortOrder = "LayoutOrder",
			Padding = UDim.new(0, 12),
		}),
		New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			LayoutOrder = 1,
		}, {
			New("UIListLayout", {
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
				Padding = UDim.new(0, 8),
			}),
			IconFrame,
			Title,
		}),
		New("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = "Y",
			LayoutOrder = 2,
		}, {
			New("UIListLayout", {
				SortOrder = "LayoutOrder",
				Padding = UDim.new(0, 4),
			}),
			ValueLabel,
			DescLabel,
		})
	}, true, true)

	StatCardModule.ElementFrame = Main

	function StatCardModule:SetValue(val)
		StatCardModule.Value = val
		ValueLabel.Text = tostring(val)
	end

	function StatCardModule:SetDesc(desc)
		StatCardModule.Desc = desc
		if DescLabel then
			DescLabel.Text = tostring(desc)
		end
	end

	return StatCardModule.__type, StatCardModule
end

return Element