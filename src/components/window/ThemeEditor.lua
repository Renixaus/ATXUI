--!strict
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local HttpService = cloneref(game:GetService("HttpService"))
local Creator = require("../../modules/Creator")

local ThemeEditor = {}

function ThemeEditor.Create(Window, ParentTab, ATXUI)
	local EditorTab = ParentTab or Window:Tab({
		Title = "Theme Editor",
		Icon = "palette"
	})

	local currentTheme = Creator.Theme

	-- Properties that are usually Color3 in themes
	local themeProperties = {
		"Accent", "Background", "Text", "Button", "Icon", "Toggle", "Slider", "Checkbox", "Dialog", "Placeholder"
	}

	for _, prop in ipairs(themeProperties) do
		local initialColor = currentTheme[prop]
		if typeof(initialColor) == "Color3" then
			EditorTab:Colorpicker({
				Title = prop .. " Color",
				Default = initialColor,
				Callback = function(color)
					Creator.Theme[prop] = color
					Creator.UpdateTheme()
				end
			})
		elseif typeof(initialColor) == "string" and initialColor:match("^#") then
			EditorTab:Colorpicker({
				Title = prop .. " Color",
				Default = Color3.fromHex(initialColor),
				Callback = function(color)
					Creator.Theme[prop] = color
					Creator.UpdateTheme()
				end
			})
		end
	end

	EditorTab:Button({
		Title = "Copy Theme Data",
		Desc = "Copies the current theme colors to your clipboard as a Lua table.",
		Icon = "clipboard-copy",
		Callback = function()
			local themeData = "{\n"
			themeData = themeData .. '    Name = "CustomTheme",\n'
			for _, prop in ipairs(themeProperties) do
				local color = Creator.Theme[prop]
				if typeof(color) == "Color3" then
					themeData = themeData .. string.format('    %s = Color3.fromRGB(%d, %d, %d),\n', prop, math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255))
				end
			end
			themeData = themeData .. "}"

			if setclipboard then
				setclipboard(themeData)
				ATXUI:Notify({
					Title = "Theme Copied",
					Content = "The theme data has been copied to your clipboard.",
					Duration = 3
				})
			else
				warn("setclipboard is not supported on this executor.\n" .. themeData)
			end
		end
	})

	return EditorTab
end

return ThemeEditor
